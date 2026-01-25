# Validating NixOS flake changes before committing

**Flake-level:**
```bash
nix flake check
nix flake show
nix flake check --no-build
```

**System-level:**
```bash
nixos-rebuild build
nixos-rebuild test
nixos-rebuild dry-build
nixos-rebuild dry-activate
```

**Interactive:**
```bash
nix repl
> :lf /path/to/flake.nix
> nixosConfigurations.<hostname>.config.system.build.toplevel
```

**Flake ops:**
```bash
nix flake update
nix flake update --commit-lock-file --dry-run
nix flake update --update-input nixpkgs
```

**Remote testing:**
```bash
nixos-rebuild test --target-host user@host --build-host localhost
nixos-rebuild switch --target-host user@host
```

Src: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html, https://nixos.org/manual/nixos/stable/#sec-changing-config
