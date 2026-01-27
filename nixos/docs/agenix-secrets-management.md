# Agenix Secrets Management with Age Encryption

## Overview

Agenix is a NixOS tool for securely managing and deploying secrets using age encryption with SSH public-private key pairs. It solves the problem of storing sensitive data in the world-readable Nix store by encrypting secrets and decrypting them only at system activation time.

## Key Concepts

### Age Encryption
Agenix uses the `age` encryption tool for encrypting secrets. Age is a modern, simple file encryption tool that supports:
- **SSH key encryption**: Uses existing SSH public/private keys
- **Multiple recipients**: Secrets can be encrypted for multiple systems/users
- **X25519**: Default cryptographic primitive (post-quantum safe)

### How It Works
1. **Encryption**: Secrets are encrypted using public SSH keys into `.age` files
2. **Storage**: Encrypted `.age` files are stored in git and copied to the Nix store
3. **Decryption**: During system activation, secrets are decrypted using private SSH keys
4. **Mounting**: Decrypted secrets are symlinked to `/run/agenix/<name>` by default

## Implementation Workflow

### 1. Installation via Flakes

Add agenix to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add agenix input
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Import the module in your configuration:

```nix
{
  outputs = { self, nixpkgs, home-manager, agenix, ... }: {
    nixosConfigurations.nixos-arm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit agenix; };  # Pass agenix to modules
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default  # Add this line
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.wesbragagt = {
            imports = [ ./home.nix ];
          };
        }
      ];
    };
  };
}
```

Install the agenix CLI tool:

```nix
{
  environment.systemPackages = [ agenix.packages.${system}.default ];
}
```

### 2. Create Secrets Directory

Create a directory for secrets (outside of version control):

```bash
mkdir -p secrets
cd secrets
```

### 3. Define Encryption Rules (secrets.nix)

Create a `secrets.nix` file that specifies which public keys can decrypt each secret:

```nix
let
  # User SSH public keys (from ~/.ssh/id_ed25519.pub or GitHub keys)
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  users = [ user1 ];

  # System SSH public keys (from target machine)
  # Get these with: ssh-keyscan <ip-address>
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  systems = [ system1 ];
in
{
  # Define which keys can decrypt each secret
  "password.age".publicKeys = [ user1 system1 ];
  "api-key.age".publicKeys = users ++ systems;
}
```

**Getting Public Keys:**

From local machine:
```bash
cat ~/.ssh/id_ed25519.pub
```

From remote machine:
```bash
ssh-keyscan 192.168.71.3
```

From GitHub:
```bash
curl https://github.com/ryantm.keys
```

### 4. Create Encrypted Secret

Use the agenix CLI to create a new secret:

```bash
# This opens $EDITOR (vim, nvim, etc.)
agenix -e password.age
```

Enter your secret content in the editor and save. Agenix will automatically encrypt it using the public keys defined in `secrets.nix`.

### 5. Define Secret in Nix Configuration

Add the secret to your NixOS or Home Manager configuration:

```nix
{
  # For NixOS system secrets
  age.secrets.password = {
    file = ../secrets/password.age;
    mode = "640";
    owner = "root";
    group = "root";
  };

  # For Home Manager user secrets
  age.secrets.user-password = {
    file = ../secrets/password.age;
    mode = "600";
    owner = "wesbragagt";
    group = "users";
  };
}
```

### 6. Reference Secret in Configuration

Use the secret's path in your configuration:

```nix
{
  # Example: user password
  users.users.wesbragagt = {
    isNormalUser = true;
    passwordFile = config.age.secrets.user-password.path;
  };

  # Example: service configuration
  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    config.adminpassFile = config.age.secrets.nextcloud-password.path;
  };
}
```

### 7. Deploy Configuration

Build and deploy as usual:

```bash
# On local machine
git add .
git commit -m "feat: add secrets management with agenix"
git push

# On VM
cd ~/.dotfiles
git pull
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm
```

The secret will be decrypted during system activation and mounted to `/run/agenix/password` by default.

## Git Integration

### Version Control Structure

```
nixos/
├── secrets/
│   ├── secrets.nix        # Public key definitions (version controlled)
│   ├── password.age       # Encrypted secret (version controlled)
│   ├── api-key.age        # Encrypted secret (version controlled)
│   └── .gitignore         # Ignore plaintext files
├── configuration.nix
├── home.nix
└── flake.nix
```

### .gitignore for Secrets

```gitignore
# Ignore any plaintext secret files (should never exist)
*.txt
*.key
*.pem

# Keep .age files (they're encrypted)
!*.age
```

### Committing Secrets

Encrypted `.age` files can be safely committed to git:

```bash
git add secrets/password.age secrets/secrets.nix
git commit -m "feat: add encrypted password secret"
git push
```

## Editing and Rekeying Secrets

### Edit Existing Secret

```bash
# Opens editor with decrypted content
agenix -e password.age

# With specific private key
agenix -e password.age -i ~/.ssh/id_ed25519
```

### Rekey All Secrets

If you change the public keys in `secrets.nix`, rekey all secrets:

```bash
agenix --rekey
```

This decrypts and re-encrypts all secrets with the new public keys.

### Decrypt Secret to View

```bash
# Decrypt and print to stdout
agenix -d password.age

# Decrypt to file
agenix -d password.age > password.txt
```

## Advanced Configuration

### Custom Secret Paths

```nix
{
  age.secrets.nginx-htpasswd = {
    file = ../secrets/nginx-htpasswd.age;
    path = "/etc/nginx/htpasswd";  # Custom path
    mode = "640";
    owner = "nginx";
    group = "nginx";
  };
}
```

### Symlink vs Copy

```nix
{
  age.secrets."elasticsearch.conf" = {
    file = ../secrets/elasticsearch.conf.age;
    symlink = false;  # Copy instead of symlink (for Java apps)
  };
}
```

### Custom Secret Name

```nix
{
  age.secrets.monit = {
    name = "monitrc";  # Different filename than attr name
    file = ../secrets/monitrc.age;
  };
}
```

### Custom Identity Paths

```nix
{
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/etc/ssh/ssh_host_rsa_key"
  ];
}
```

## Security Considerations

### Threat Model
- **Attackers with write access**: Can modify secrets since age doesn't provide authentication
- **Post-quantum security**: Age uses X25519 which is not post-quantum safe (as of June 2024)
- **Harvest now, decrypt later**: Consider rotating secrets periodically

### Best Practices
1. **Rotate secrets regularly** (especially high-value secrets)
2. **Limit SSH access** to those who should decrypt secrets
3. **Avoid `builtins.readFile`** on secret paths (puts plaintext in Nix store)
4. **Use separate keys** for different security domains
5. **Backup private keys** securely

### Anti-Pattern: builtins.readFile

```nix
# ❌ BAD - This puts plaintext in the Nix store
config.password = builtins.readFile config.age.secrets.password.path;

# ✅ GOOD - Let services read at runtime
services.myapp = {
  passwordFile = config.age.secrets.password.path;
};
```

## Troubleshooting

### Secret Not Decrypting
- Verify private key exists at `age.identityPaths`
- Check public key in `secrets.nix` matches private key
- Ensure secret was encrypted with the correct public key

### "Identity not found" Error
- Check that SSH is enabled: `services.openssh.enable = true`
- Verify host keys exist: `ls -la /etc/ssh/ssh_host_*`
- Use `age.identityPaths` to specify custom key location

### Password-Protected SSH Keys
Age doesn't support ssh-agent, so you'll need to enter password for each operation. Consider using passwordless keys for secrets management or use `ssh-keygen` to create a dedicated key without a passphrase.

### Impermanence with Host Keys
If using impermanence, ensure host keys are persisted:

```nix
{
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/etc/ssh/ssh_host_rsa_key"
  ];
}
```

## Comparison with Alternatives

| Tool | Encryption | Git Storage | MAC | Complexity |
|------|------------|--------------|-----|------------|
| **agenix** | age | Yes | ❌ | Low |
| **sops-nix** | age/GPG/KMS | Yes | ✅ | Medium |
| **git-crypt** | AES-256 | Yes | ✅ | Low |
| **deployment.keys** | None | No | ❌ | Low |

Agenix advantages:
- Simple, minimal codebase (easy to audit)
- Uses existing SSH infrastructure
- No GPG required
- Works with git out of the box

## Sources

- **Agenix Repository**: https://github.com/ryantm/agenix
- **Agenix Documentation**: https://git.dgnum.eu/DGNum/agenix
- **NixOS Wiki - Agenix**: https://wiki.nixos.org/wiki/Agenix
- **Age Encryption Tool**: https://github.com/FiloSottile/age
- **Age Encryption Website**: https://age-encryption.org/
- **Managing Secrets with Agenix**: https://sawyershepherd.org/post/managing-secrets-in-nixos-with-agenix/
- **Handling Secrets in NixOS**: https://discourse.nixos.org/t/handling-secrets-in-nixos-an-overview-git-crypt-agenix-sops-nix-and-when-to-use-them/35462
- **Comparison of Secret Schemes**: https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes
- **Encrypting Secrets in NixOS with Agenix**: https://mich-murphy.com/encrypting-secrets-nixos/

## Example: Complete Setup for This Repository

### 1. Update flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:LunaCOLON3/zen-browser-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add agenix
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, agenix, ... }: {
    nixosConfigurations.nixos-arm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        { 
          nixpkgs.overlays = [ zen-browser.overlay ];
          nixpkgs.config.allowUnsupportedSystem = true;
        }
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default  # Add agenix module
        {
          nix.settings = {
            extra-substituters = [
              "https://walker.cachix.org"
              "https://walker-git.cachix.org"
            ];
            extra-trusted-public-keys = [
              "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
              "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
            ];
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.wesbragagt = { config, pkgs, lib, ... }: {
            imports = [
              ./home.nix
              zen-browser.homeManagerModules.zen-browser
            ];
          };
        }
      ];
    };
  };
}
```

### 2. Add agenix CLI to packages (configuration.nix)

```nix
{ config, pkgs, agenix, ... }: {
  environment.systemPackages = with pkgs; [
    agenix.packages.${pkgs.system}.default  # Architecture-agnostic
  ];
}
```

**Note:** Pass `agenix` via `specialArgs` in your flake outputs:

```nix
{
  outputs = { self, nixpkgs, home-manager, agenix, ... }: {
    nixosConfigurations.nixos-arm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit agenix; };
      modules = [ ./configuration.nix ];
    };
  };
}
```

### 3. Create secrets directory and secrets.nix

```bash
mkdir -p secrets
```

`secrets/secrets.nix`:
```nix
let
  # Get your user public key
  # cat ~/.ssh/id_ed25519.pub
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";

  # Get VM host key
  # ssh-keyscan 192.168.71.3
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
in
{
  "test-secret.age".publicKeys = [ user system ];
}
```

### 4. Create a secret

```bash
cd secrets
agenix -e test-secret.age
# Enter your secret and save
```

### 5. Add secret to configuration

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

### 6. Deploy

```bash
# On local machine
git add secrets/secrets.nix secrets/test-secret.age flake.nix configuration.nix
git commit -m "feat: add agenix secrets management"
git push

# On VM
cd ~/.dotfiles
git pull
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm
```

### 7. Verify

```bash
# On VM
ls -la /run/agenix/test-secret
cat /run/agenix/test-secret
```

The secret should be decrypted and available at `/run/agenix/test-secret`.
