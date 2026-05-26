{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;
  };

  services = {
    hyprpolkitagent.enable = true;
    hypridle.enable = true;
    hyprpaper.enable = true;
    hyprlauncher.enable = true;
  };

  programs = {
    hyprshot.enable = true;
    waybar.enable = true;
  };

  home.packages = with pkgs; [
    nautilus
  ];

  xdg.configFile = {
    "hypr/hyprland.lua" = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/hypr/hyprland.lua";
  };
}
