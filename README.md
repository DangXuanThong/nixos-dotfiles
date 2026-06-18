`nixos-dotfile` is where I store my [NixOS](https://github.com/NixOS/nixpkgs) configuration files, with [Flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager)

## How to use
### Option 1. First-time installation on a fresh NixOS system:
```bash
# Clone the repo
git clone https://github.com/dangxuanthong/nixos-dotfiles.git ~/nixos-dotfiles

# Replace /etc/nixos with a symlink to the cloned repo
sudo rm -rf /etc/nixos
sudo ln -s ~/nixos-dotfiles /etc/nixos

# Fix permissions so the nix evaluator can read files through the symlink
chmod -R o+rX ~/nixos-dotfiles

# Generate hardware configuration for this machine
sudo nixos-generate-config

# Rebuild
sudo nixos-rebuild switch --impure
```

### Option 2. Use directly without cloning:
```bash
sudo nixos-rebuild switch --flake --impure github:dangxuanthong/nixos-dotfiles#Nix-PC
```

### Option 3. Clone the repo and build from it locally:
```bash
git clone https://github.com/dangxuanthong/nixos-dotfiles.git ~/nixos-dotfiles && cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake . --impure
```
