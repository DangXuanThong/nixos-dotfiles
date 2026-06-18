# nixos-dotfiles

My personal [NixOS](https://nixos.org) configuration using [Flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).

**Desktop:** KDE Plasma 6. For the Hyprland setup, see the [`hyprland-preview`](https://github.com/DangXuanThong/nixos-dotfiles/tree/hyprland-preview) branch.

## Installation

> **Note:** The flake targets hostname `Nix-PC` (set in `configuration.nix`). On a fresh install, either set the hostname to `Nix-PC` during setup or update it in `configuration.nix` before rebuilding.

> `hardware-configuration.nix` is machine-specific and gitignored — `nixos-generate-config` will write it into the repo folder through the symlink.

### Fresh NixOS system

```bash
git clone https://github.com/DangXuanThong/nixos-dotfiles.git ~/nixos-dotfiles

sudo rm -rf /etc/nixos
sudo ln -s ~/nixos-dotfiles /etc/nixos

sudo nixos-generate-config
sudo nixos-rebuild switch --impure
```

### Build directly from GitHub (no clone)

```bash
sudo nixos-rebuild switch --flake github:DangXuanThong/nixos-dotfiles#Nix-PC --impure
```

### Clone and rebuild locally (for ongoing edits)

```bash
git clone https://github.com/DangXuanThong/nixos-dotfiles.git ~/nixos-dotfiles
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake . --impure
```

## Updating

```bash
nix-update   # flake update + rebuild
nix-rebuild  # rebuild only
```
