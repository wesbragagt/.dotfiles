# Bitwarden Setup

## Installation

Bitwarden desktop application is installed via Nix in `modules/bitwarden.nix`.

## Desktop App Setup

The Bitwarden desktop app (`bitwarden-desktop`) is automatically installed via Home Manager. You can launch it from your application launcher or from the command line:

```bash
bitwarden-desktop
```

## Login with CLI

Login to your Bitwarden vault:

```bash
bw login
```

For self-hosted instances:

```bash
bw login --server https://your-bitwarden-server.com
```

After login, unlock the vault:

```bash
bw unlock
```

The unlock command will export an environment variable `BW_SESSION` that you can use for subsequent commands, or you can just run `bw unlock` and follow the prompts.

## SSH Agent Setup

### Enable SSH Agent in Desktop App

1. Open Bitwarden desktop app
2. Go to Settings
3. Enable "SSH agent"
4. The SSH agent socket will be created at `$HOME/.bitwarden-ssh-agent.sock`

### Add SSH Keys to Bitwarden

1. In Bitwarden, create a new vault item
2. Add an SSH key field
3. Paste your private key or generate a new one

### Configure SSH to Use Bitwarden Agent

The `SSH_AUTH_SOCK` environment variable is automatically set to `$HOME/.bitwarden-ssh-agent.sock` via the Nix configuration.

Test it works:

```bash
ssh-add -l
```

This should list your SSH keys stored in Bitwarden.

### Using SSH

```bash
ssh user@host
```

Bitwarden will prompt you to approve the SSH key usage in the desktop app.

## Common Commands

```bash
# Login
bw login

# Unlock (keep session active for terminal)
bw unlock

# List items in vault
bw list items

# Get item details
bw get item <item-id>

# Sync vault
bw sync

# Lock vault
bw lock
```

## References

- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/)
- [Bitwarden SSH Agent](https://bitwarden.com/help/ssh-agent/)
- [Using Bitwarden as SSH Agent](https://wyssmann.com/blog/2026/01/user-bitwarden-as-ssh-agent/)
