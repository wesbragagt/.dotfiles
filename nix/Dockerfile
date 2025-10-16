FROM nixos/nix:latest

# Enable flakes
RUN nix --experimental-features "nix-command flakes" profile install nixpkgs#nixFlakes

# Set environment
ENV USER=testuser
ENV HOME=/home/testuser

# Create user directory
RUN mkdir -p $HOME && chown -R 1000:1000 $HOME

# Copy the flake
COPY . /app
WORKDIR /app

# Test the setup
CMD ["nix", "develop", "--command", "bash", "-c", "echo '🧪 Testing Neovim setup in Docker...' && nvim --version | head -n1 && echo '✅ Neovim accessible!'"]