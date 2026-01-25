# NixOS Home-Manager Flake Errors - Fixes

## 1. Invalid SRI Hash Error

**Error**: `error: invalid SRI hash '06kjzacn6ikj7vj1av9k88x12gdp9v5l46ijhyzl106md91clkx0'`

**Location**: `modules/nvim/default.nix:12`

**Issue**: The hash for neovim commit `c39d18ee93` is incorrect.

**Fix**:

Option 1 - Get correct hash via nix-prefetch-git (on the VM):
```bash
nix-prefetch-git --url https://github.com/neovim/neovim.git --rev c39d18ee93
```

Option 2 - Use a more recent stable neovim version:
```nix
neovim-custom = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
  version = "v0.12.0";
  src = pkgs.fetchFromGitHub {
    owner = "neovim";
    repo = "neovim";
    rev = "v0.12.0";  # Use tag instead of commit
    sha256 = "sha256-PUT_CORRECT_HASH_HERE";  # Update after getting hash
  };
});
```

Option 3 - Use the default neovim from nixpkgs:
```nix
# In home.nix, replace the custom module with:
home.packages = with pkgs; [ neovim ];

programs.neovim = {
  enable = true;
  defaultEditor = true;
};
```

**Reference**: Home-Manager issue #3044 discusses SRI hash issues with fetchFromGitHub.

## 2. Pointer Cursor Configuration

**Issue**: Removed `home.pointerCursor` block, wondering if it's necessary.

**Findings**:
- `home.pointerCursor` is the correct home-manager option for cursor configuration
- Hyprland (Wayland) uses `XCURSOR_THEME` and `XCURSOR_SIZE` environment variables
- GTK applications need `gtk.enable = true` for cursor theme
- XWayland applications need `x11.enable = true`

**Fix**:

Re-add the cursor configuration to `home.nix`:
```nix
home.pointerCursor = {
  name = "Vanilla-DMZ";
  package = pkgs.vanilla-dmz;
  size = 24;
  gtk.enable = true;  # For GTK applications
  x11.enable = true;  # For XWayland applications
};
```

**Alternative**: System-wide cursor configuration in `configuration.nix`:
```nix
fonts.fontconfig.enable = true;  # Enables fontconfig for user profiles
# Note: Cursors are typically handled at user level, not system level
```

**Reference**: Home-Manager options for `home.pointerCursor` and GitHub issue #4553 for cursor theme inconsistencies.

## 3. Tuigreet Package Rename

**Warning**: `evaluation warning: 'greetd.tuigreet' was renamed to 'tuigreet'`

**Location**: `configuration.nix:57`

**Issue**: Package was moved from `pkgs.greetd.tuigreet` to `pkgs.tuigreet` on August 2, 2025.

**Fix**:

Change line 57 in `configuration.nix` from:
```nix
command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --remember --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop'";
```

To:
```nix
command = "${pkgs.tuigreet}/bin/tuigreet --asterisks --remember --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop'";
```

**Reference**: GitHub commit 3d98a4985618ad4c76c006b3c4942beb1a9aabfb - "greetd.*: move to 'pkgs/by-name' and top level"

## Summary

1. **SRI Hash**: Update the hash in `modules/nvim/default.nix` or switch to using nixpkgs neovim
2. **Cursor Config**: Re-add `home.pointerCursor` to `home.nix` - it's necessary for proper cursor theming
3. **Tuigreet**: Change `pkgs.greetd.tuigreet` to `pkgs.tuigreet` in `configuration.nix`

## Verification

After applying fixes:
```bash
nix flake check
```

Should pass without errors.
