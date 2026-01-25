# Starship with NixOS and Home Manager

## Configuration

Enable starship in home-manager:

```nix
programs.starship = {
  enable = true;
  settings = {
    # Configuration written to ~/.config/starship.toml
    add_newline = false;
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold red)";
    };
  };
};
```

## Integration with zsh

Starship works automatically with zsh when enabled via home-manager. The starship initialization is handled by home-manager, no manual `eval "$(starship init zsh)"` needed.

## Example Full Configuration

```nix
programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    aws.disabled = true;
    gcloud.disabled = true;
    line_break.disabled = true;
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✗](bold red)";
    };
  };
};
```

## Sources

- Starship docs: https://starship.rs/config/
- Home Manager option: https://nix-community.github.io/home-manager/options.xhtml
- NixOS Wiki: https://wiki.nixos.org/wiki/Starship
