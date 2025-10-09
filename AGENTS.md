# Repository Guidelines

## Project Structure & Module Organization
- Each top-level directory mirrors a tool’s config root (for example `nvim/.config/nvim`, `zsh/.config/zsh`, `tmux/.config/tmux`), enabling GNU Stow to place files in `$HOME`.
- Platform-specific bundles live beside shared ones (`karabiner/`, `ghostty/`, `wezterm/` for macOS; `keyd/` for Linux). Keep new modules consistent with this pattern.
- Scripts and helpers reside in `utils/`; keep executable bits set and document new scripts with a short header comment.
- Static assets such as wallpapers and Raycast assets belong in `wallpapers/` and `raycast/` respectively.

## Build, Test, and Development Commands
- `./setup.sh` runs `stow --adopt` across the curated module list; use it after any structure change to resync symlinks.
- `./clean.sh` detaches managed symlinks via `stow -D`; run before removing or renaming modules.
- `nix develop` enters the flake-defined environment with Neovim nightly, Stow, and other CLI tooling that matches production assumptions.
- For one-off checks, prefer `stow <module> --simulate` to preview link changes without editing the working tree.

## Coding Style & Naming Conventions
- Shell scripts use Bash with two-space indentation, lowercase filenames, and executable shebangs (`#!/bin/bash`). Mirror existing spacing around arrays and control blocks.
- Nix files (see `flake.nix`) follow two-space indentation and trailing commas on multi-line lists.
- Config filenames should reflect their upstream app naming (`alacritty/alacritty.toml`, `starship/starship.toml`) so Stow places them predictably.
- Keep secrets or machine overrides out of shared modules; prefer `secrets/` for encrypted or ignored content.

## Testing Guidelines
- Before committing, run `stow <module> --simulate` or `./setup.sh` in a temporary directory to ensure symlinks resolve and no unexpected overwrites occur.
- Validate the Nix environment with `nix develop --command nvim --version` (or another primary tool) to confirm overlay updates succeed.
- Manual smoke tests (e.g., launching tmux, ghostty, or wezterm) remain the primary verification; document any tool-specific checklist additions inside the module README if required.

## Commit & Pull Request Guidelines
- Follow the existing Conventional Commit style (`feat:`, `chore:`, `fix:`). Example: `feat: add wezterm color theme`.
- Squash fixups locally and ensure commits only touch the modules they describe.
- Pull requests should describe affected tools, note the target OS, list verification steps (`./setup.sh`, manual launches), and include screenshots or GIFs when altering visual themes.
- Link related issues or discussions when available and call out any required manual follow-up (e.g., reinstalling plugins).
