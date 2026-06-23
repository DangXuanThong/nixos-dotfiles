# nixos-dotfiles

My personal [NixOS](https://nixos.org) configuration using [Flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).

This is the **`hyprland-preview`** branch. For the stable KDE Plasma 6 desktop, see the [`main`](https://github.com/DangXuanThong/nixos-dotfiles/tree/main) branch.

## Default apps

| Role | App | Config |
|------|-----|--------|
| Window manager | Hyprland | [config/hypr](config/hypr) |
| Bar | Waybar | [config/waybar](config/waybar) |
| App launcher | Hyprlauncher | [modules/hyprland.nix](modules/hyprland.nix) |
| Browser | Zen Browser | [modules/zen-browser.nix](modules/zen-browser.nix) |
| Shell | Fish | [modules/fish.nix](modules/fish.nix) |
| File manager | Nautilus | [modules/hyprland.nix](modules/hyprland.nix) |
| Image viewer | Loupe | [modules/hyprland.nix](modules/hyprland.nix) |
| Video player | Celluloid | [modules/hyprland.nix](modules/hyprland.nix) |
| Text editor | GNOME Text Editor | [modules/hyprland.nix](modules/hyprland.nix) |
| System monitor | Mission Center | [modules/hyprland.nix](modules/hyprland.nix) |
| Archive manager | File Roller | [modules/hyprland.nix](modules/hyprland.nix) |
| Notifications | Dunst | [modules/hyprland.nix](modules/hyprland.nix) |
| Lock screen | Hyprlock | [modules/hyprland.nix](modules/hyprland.nix) |
| Flatpak apps | nix-flatpak | [modules/flatpak.nix](modules/flatpak.nix) |

## Installation

> **Note:** The flake targets hostname `Nix-PC` (set in `configuration.nix`). On a fresh install, either set the hostname to `Nix-PC` during setup or update it in `configuration.nix` before rebuilding.

> `hardware-configuration.nix` is machine-specific and gitignored — `nixos-generate-config` will write it into the repo folder through the symlink.

> The first rebuild commands below set `NIX_CONFIG` inline so they work before flakes are enabled globally. After the first switch, `configuration.nix` enables `nix-command` and `flakes` persistently.

### Fresh NixOS system

```bash
nix-shell -p git --run 'git clone --branch hyprland-preview https://github.com/DangXuanThong/nixos-dotfiles.git ~/nixos-dotfiles'

sudo rm -rf /etc/nixos
sudo ln -s ~/nixos-dotfiles /etc/nixos

# Fix permissions so the nix evaluator can read files through the symlink
chmod -R o+rX ~/nixos-dotfiles

sudo nixos-generate-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#Nix-PC --impure
```

### Build directly from GitHub (no clone)

```bash
sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake github:DangXuanThong/nixos-dotfiles/hyprland-preview#Nix-PC --impure
```

### Clone and rebuild locally (for ongoing edits)

```bash
nix-shell -p git --run 'git clone --branch hyprland-preview https://github.com/DangXuanThong/nixos-dotfiles.git ~/nixos-dotfiles'
cd ~/nixos-dotfiles
sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#Nix-PC --impure
```

## Updating

```bash
nix-update   # flake update + rebuild
nix-rebuild  # rebuild only
nix-cleanup  # keep latest 5 system generations + garbage collect
```
