#!/usr/bin/env python3
"""Compress / decompress a folder with live progress.

Usage:
    compression.py compress   <folder> [-o|--out PATH]
    compression.py decompress <archive.tar.zst> [-o|--out DIR]

Defaults:
    compress   → ./<folder-basename>-<YYYYMMDD-HHMM>.tar.zst
    decompress → current working directory

Excludes common build/cache/data dirs on compress: node_modules .next dist
build target .venv __pycache__ .cache data  (override with --no-excludes).

Progress is measured against:
    compress   — total on-disk size of the source (pre-compression)
    decompress — size of the archive on disk (post-compression)
"""
from __future__ import annotations

import os
import shutil
import signal
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

EXCLUDES = (
    "node_modules", ".next", "dist", "build",
    "target", ".venv", "__pycache__", ".cache", "data",
    ".terragrunt-cache",
)


def fail(msg: str, code: int = 1) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def human(n: float) -> str:
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if n < 1024:
            return f"{n:6.2f} {unit}"
        n /= 1024
    return f"{n:6.2f} PiB"


def fmt_dur(secs: float) -> str:
    secs = int(secs)
    h, rem = divmod(secs, 3600)
    m, s = divmod(rem, 60)
    return f"{h:02d}:{m:02d}:{s:02d}" if h else f"{m:02d}:{s:02d}"


def require_tools(*tools: str) -> None:
    missing = [t for t in tools if not shutil.which(t)]
    if missing:
        fail(f"missing tools: {', '.join(missing)}")


def measure_dir(path: Path, excludes: tuple[str, ...]) -> int:
    args = ["du", "-sb"]
    args += [f"--exclude={ex}" for ex in excludes]
    args.append(str(path))
    return int(subprocess.check_output(args, text=True).split()[0])


def stream_with_progress(
    label: str,
    producer: subprocess.Popen,
    consumer_stdin_fd: int,
    total: int,
) -> int:
    start = time.monotonic()
    moved = 0
    last = 0.0
    bar_w = 30
    try:
        with os.fdopen(consumer_stdin_fd, "wb") as out:
            while True:
                chunk = producer.stdout.read(1024 * 1024)
                if not chunk:
                    break
                out.write(chunk)
                moved += len(chunk)
                now = time.monotonic()
                if now - last >= 0.25:
                    elapsed = now - start
                    rate = moved / elapsed if elapsed > 0 else 0
                    pct = moved / total if total else 0
                    eta = (total - moved) / rate if rate > 0 else 0
                    filled = max(0, min(bar_w, int(pct * bar_w)))
                    bar = "█" * filled + "░" * (bar_w - filled)
                    pct_disp = min(pct, 1.0)
                    sys.stdout.write(
                        f"\r  {label} [{bar}] {pct_disp*100:5.1f}%  "
                        f"{human(moved)} / {human(total)}  "
                        f"{human(rate)}/s  ETA {fmt_dur(eta)}   "
                    )
                    sys.stdout.flush()
                    last = now
    finally:
        producer.stdout.close()
    print()
    return moved


def install_sigint(procs: list) -> None:
    def cleanup(_s, _f):
        for p in procs:
            if p.poll() is None:
                p.terminate()
        sys.exit(130)
    signal.signal(signal.SIGINT, cleanup)


def _pop_flag_value(argv: list, *names: str) -> "str | None":
    """Remove and return the value for any of `names` (--out, -o, --out=X)."""
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in names:
            if i + 1 >= len(argv):
                fail(f"{a} requires a value")
            val = argv[i + 1]
            del argv[i:i + 2]
            return val
        for n in names:
            if a.startswith(n + "="):
                val = a.split("=", 1)[1]
                del argv[i]
                return val
        i += 1
    return None


def cmd_compress(argv: list) -> int:
    require_tools("tar", "zstd", "du")
    out = _pop_flag_value(argv, "--out", "-o")
    use_excludes = True
    if "--no-excludes" in argv:
        use_excludes = False
        argv = [a for a in argv if a != "--no-excludes"]
    if not argv:
        fail("usage: compress <folder> [-o PATH]")

    src = Path(argv[0]).expanduser().resolve()
    if not src.is_dir():
        fail(f"{src} is not a directory")

    # Positional output still accepted for back-compat
    if out is None and len(argv) > 1:
        out = argv[1]

    if out:
        dest = Path(out).expanduser().resolve()
    else:
        ts = datetime.now().strftime("%Y%m%d-%H%M")
        dest = Path.cwd() / f"{src.name}-{ts}.tar.zst"
    dest.parent.mkdir(parents=True, exist_ok=True)

    excludes = EXCLUDES if use_excludes else ()

    print(f"→ Source     : {src}")
    print(f"→ Destination: {dest}")
    print("→ Measuring source size...")
    total = measure_dir(src, excludes)
    print(f"→ Source size: {human(total)}")

    tar_args = ["tar", "-cf", "-"]
    if use_excludes:
        # Honor per-directory .gitignore files and ignore .git internals.
        tar_args += ["--exclude-vcs-ignores", "--exclude-vcs"]
    tar_args += [f"--exclude={ex}" for ex in excludes]
    tar_args += ["-C", str(src.parent), src.name]
    tar = subprocess.Popen(tar_args, stdout=subprocess.PIPE)
    pr_r, pr_w = os.pipe()
    with open(dest, "wb") as out_file:
        zstd = subprocess.Popen(
            ["zstd", "-T0", "-3"],
            stdin=pr_r, stdout=out_file,
        )
        os.close(pr_r)

        install_sigint([tar, zstd])
        start = time.monotonic()
        stream_with_progress("compress  ", tar, pr_w, total)

        rcs = (tar.wait(), zstd.wait())
        if any(rcs):
            fail(f"pipeline failed: tar={rcs[0]} zstd={rcs[1]}", 2)

    out_size = dest.stat().st_size
    elapsed = time.monotonic() - start
    ratio = (out_size / total) if total else 0
    print(f"→ Wrote {human(out_size)} ({ratio*100:.1f}% of source) in {fmt_dur(elapsed)}")
    print(f"→ {dest}")
    return 0


def cmd_decompress(argv: list) -> int:
    require_tools("tar", "zstd")
    out = _pop_flag_value(argv, "--out", "-o")
    if not argv:
        fail("usage: decompress <archive.tar.zst> [-o DIR]")

    archive = Path(argv[0]).expanduser().resolve()
    if not archive.is_file():
        fail(f"{archive} is not a file")

    if out is None and len(argv) > 1:
        out = argv[1]
    target = Path(out).expanduser().resolve() if out else Path.cwd()
    target.mkdir(parents=True, exist_ok=True)

    total = archive.stat().st_size
    print(f"→ Archive    : {archive}  ({human(total)})")
    print(f"→ Extract to : {target}")

    src = open(archive, "rb")
    feeder = subprocess.Popen(["cat"], stdin=src, stdout=subprocess.PIPE)
    src.close()
    pr_r, pr_w = os.pipe()
    zstd = subprocess.Popen(["zstd", "-d", "-T0"], stdin=pr_r, stdout=subprocess.PIPE)
    os.close(pr_r)
    tar = subprocess.Popen(
        ["tar", "-xf", "-", "-C", str(target)],
        stdin=zstd.stdout,
    )
    zstd.stdout.close()

    install_sigint([feeder, zstd, tar])
    start = time.monotonic()
    stream_with_progress("decompress", feeder, pr_w, total)

    rcs = (feeder.wait(), zstd.wait(), tar.wait())
    if any(rcs):
        fail(f"pipeline failed: read={rcs[0]} zstd={rcs[1]} tar={rcs[2]}", 2)

    print(f"→ Done in {fmt_dur(time.monotonic() - start)}")
    print(f"→ Extracted to {target}")
    return 0


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        return 1
    cmd, *rest = sys.argv[1:]
    handlers = {
        "compress": cmd_compress, "c": cmd_compress,
        "decompress": cmd_decompress, "d": cmd_decompress, "extract": cmd_decompress,
    }
    if cmd not in handlers:
        fail(f"unknown command: {cmd} (use: compress | decompress)")
    return handlers[cmd](rest)


if __name__ == "__main__":
    sys.exit(main())
