# Configuring zsh with home-manager to source dotfiles

Enable zsh system-wide (`configuration.nix`): `programs.zsh.enable = true`. Set user shell: `users.users.wesbragagt.shell = pkgs.zsh`.

**home.nix:**
```nix
programs.zsh = {
  enable = true;
  initContent = lib.mkOrder 1000 ''
    source $HOME/.dotfiles/zsh/.zshrc
  '';
  plugins = [
    {
      name = "zsh-autosuggestions";
      src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
    }
    {
      name = "zsh-syntax-highlighting";
      src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
    }
  ];
};

home.file.".dotfiles/zsh" = {
  source = "${dotfiles}/zsh";
  recursive = true;
};
```

Src: https://nixos.wiki/wiki/Zsh, https://nix-community.github.io/home-manager/options.xhtml
