# NixOS Issues and Solutions

## SQLite Database Busy Error

**Issue**: `error: SQLite database '/root/.cache/nix/eval-cache-v6/...sqlite' is busy`

**Research**: https://github.com/NixOS/nix/issues/7998

**Explanation**: This is actually a warning, not a blocking error. It occurs when:
- Multiple nix processes run concurrently
- A nix process runs for longer than 10 seconds

**Fix**: Clear the eval cache
```bash
sudo rm -rf /root/.cache/nix/eval-cache-v6/*
rm -rf ~/.cache/nix/eval-cache-v6/*
```

**Note**: This is a known Nix bug (#7998) that was fixed in newer versions, but the error message format was confusing ("warning: error:").

## Imports Placement in NixOS Modules

**Issue**: `imports` inside `config` block causes evaluation errors

**Correct Pattern**:
```nix
{ config, pkgs, ... }: {
  imports = [
    # Must be at top level
    ./module1.nix
    ./module2.nix
  ];

  config = {
    # Configuration here
  };
}
```

**Incorrect Pattern**:
```nix
{ config, pkgs, ... }: {
  config = {
    imports = [
      # This will fail!
      ./module1.nix
    ];
  };
}
```

## Passwordless Sudo Security Risk

**Issue**: `security.sudo.wheelNeedsPassword = false`

**Research**: https://dev.to/patimapoochai/how-to-edit-sudoers-file-in-nixos-with-examples-4k34

**Security Implications**:
- Wheel group users can run any sudo command without password
- If a wheel user account is compromised, attacker gains full root access
- Commonly used for automation (Ansible) and convenience

**Alternatives**:
1. Use passwordless sudo for specific commands only:
```nix
security.sudo.extraRules = [
  {
    users = ["your-username"];
    commands = ["/run/wrappers/bin/passwd"];
    options = ["NOPASSWD"];
  }
];
```

2. Use `extraConfig` instead of `configFile` for ordering issues

## Sudoers Ordering

**Issue**: Custom sudoers rules may be overridden by default rules

**Research**: https://discourse.nixos.org/t/sudo-member-of-wheel-cannot-run-commands-without-password/46415

**Fix**: Use `extraConfig` instead of `configFile` for rules that need to come after default rules
```nix
security.sudo.extraConfig = ''
  # This is written AFTER default %wheel rules
  user ALL = NOPASSWD: SCRIPTS
'';
```

## Build Command Lock

**Issue**: Cannot run rebuild while another nix process is running

**Fix**: Wait for process to complete or kill it:
```bash
# Check for running processes
ps aux | grep nixos-rebuild

# Kill if needed
sudo pkill -9 -f 'nixos-rebuild'
```
