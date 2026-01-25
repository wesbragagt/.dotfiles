# Auto-start Hyprland with greetd (recommended over getty)

Getty autologin causes glitchy behavior. Use greetd with `initial_session` for clean autologin:

```nix
services.greetd = {
  enable = true;
  settings = {
    initial_session = {
      command = "uwsm start hyprland-uwsm.desktop";
      user = "username";
    };
    default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --remember --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop'";
      user = "greeter";
    };
  };
};
```

Src: https://discourse.nixos.org/t/autologin-hyprland/38159
