# DuckDB and Harlequin in NixOS

## Packages

Both are available in nixpkgs:

- **duckdb** - In-memory analytical SQL database (CLI)
- **harlequin** - SQL IDE for terminal (includes DuckDB adapter)

## Installation

### Add to home.packages

```nix
# In home.nix
home.packages = with pkgs; [
  duckdb
  harlequin
];
```

### Or Add to Module

Create `modules/data-tools.nix`:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.wesbragagt.data-tools;
in
{
  options.wesbragagt.data-tools = {
    enable = lib.mkEnableOption "Enable data analysis tools (DuckDB, Harlequin)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      duckdb
      harlequin
    ];
  };
}
```

Import and enable in `home.nix`:

```nix
imports = [
  ./modules/data-tools.nix
];

wesbragagt.data-tools.enable = true;
```

## Usage

### DuckDB CLI

```bash
# In-memory database
duckdb

# Open database file
duckdb my_data.db

# Run query
duckdb -c "SELECT * FROM my_table"
```

### Harlequin SQL IDE

```bash
# Open in-memory DuckDB
harlequin

# Open database file
harlequin my_data.db

# Read-only mode
harlequin -r my_data.db
```

## Sources

- [DuckDB in nixpkgs](https://search.nixos.org/packages?show=duckdb&type=packages)
- [Harlequin in nixpkgs](https://mynixos.com/nixpkgs/package/harlequin)
- [Harlequin Installation Docs](https://harlequin.sh/docs/getting-started)
- [Harlequin DuckDB Usage](https://harlequin.sh/docs/duckdb)
