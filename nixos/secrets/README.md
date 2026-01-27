# Agenix Secrets

This directory contains encrypted secrets managed by agenix.

## Setup Instructions

### 1. Get Your SSH Public Key

On your local machine:
```bash
cat ~/.ssh/id_ed25519.pub
```

Or get from GitHub:
```bash
curl https://github.com/YOUR_USERNAME.keys
```

### 2. Get VM Host Key

On the VM:
```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Or from your local machine:
```bash
ssh-keyscan 192.168.71.3
```

### 3. Update secrets.nix

Replace `YOUR_PUBLIC_KEY_HERE` and `SYSTEM_HOST_KEY_HERE` in `secrets.nix` with the actual keys.

### 4. Create Your First Secret

```bash
cd secrets
agenix -e test-secret.age
```

Enter your secret content in the editor that opens, then save.

### 5. Add Secret to Configuration

Add to `configuration.nix` or `home.nix`:
```nix
{
  age.secrets.test-secret = {
    file = ./secrets/test-secret.age;
    mode = "600";
    owner = "wesbragagt";
    group = "users";
  };
}
```

### 6. Use the Secret

Reference the secret path in your config:
```nix
{
  systemd.services.my-service = {
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo $(cat ${config.age.secrets.test-secret.path})'";
    };
  };
}
```

### 7. Deploy

On VM:
```bash
cd ~/.dotfiles
git pull
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm
```

**Note:** This setup is architecture-agnostic. The `agenix.packages.${pkgs.system}.default` reference automatically uses the correct package for your system architecture (aarch64-linux, x86_64-linux, etc.).

The secret will be decrypted to `/run/agenix/test-secret`.

## Useful Commands

**Edit a secret:**
```bash
agenix -e test-secret.age
```

**Decrypt to view:**
```bash
agenix -d test-secret.age
```

**Rekey all secrets** (after adding new public keys):
```bash
agenix --rekey
```

**Decrypt with specific key:**
```bash
agenix -d test-secret.age -i ~/.ssh/id_ed25519
```
