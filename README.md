`nixos-dotfile` is where I store my [NixOS](https://github.com/NixOS/nixpkgs) configuration files, with [Flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager)

## How to use
### Option 1. Use directly without cloning:
```bash
sudo nixos-rebuild switch --flake --impure github:dangxuanthong/nixos-dotfiles#Nix-PC
```
### Option 2. Clone the repo and build from it locally (for updating, ...):
```bash
git clone https://github.com/dangxuanthong/nixos-dotfiles.git ~/nixos-dotfiles && cd ~/nxios-dotfiles
sudo nixos-rebuild switch --flake . --impure
```
- Optional: Symlink /etc/nixos to nixos-dotfiles folder
```bash
sudo mv /etc/nixos /etc/nixos.bak
sudo ln -s ~/nixos-dotfiles /etc/nixos
```
