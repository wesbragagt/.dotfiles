# Agenix Secrets

This directory contains encrypted secrets managed by agenix.

## Setup Instructions

### Private Key Configuration

**Private key location:** `/home/wesbragagt/.ssh/nixos_id_ed25519`
**Private key name:** `nixos_id_ed25519`

This key is used by the VM to decrypt secrets at system boot.

### Generate the Key (VM)

On the VM, generate the dedicated private key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/nixos_id_ed25519 -C "nixos@agenix"
```

**Then add the public key to `secrets.nix`:**
```bash
cat ~/.ssh/nixos_id_ed25519.pub
```

### 1. Get Your SSH Public Key (Local Machine)

On your local machine:
```bash
cat ~/.ssh/id_ed25519.pub
```

Or get from GitHub:
```bash
curl https://github.com/YOUR_USERNAME.keys
```

### 2. Update secrets.nix

Replace the `system` key in `secrets.nix` with your new key's public key:

```nix
let
  # Your SSH public key (from local machine)
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4xsJwfA16E7aNlRCKwNWzPRNtPz5ZyKj5n+6LbWhsS";

  # VM SSH HOST KEY (nixos_id_ed25519 public key)
  # Get this from VM: cat ~/.ssh/nixos_id_ed25519.pub
  system = "ssh-ed25519 YOUR_NEW_PUBLIC_KEY_HERE";

  keys = [ user system ];
in
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
