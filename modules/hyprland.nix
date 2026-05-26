{ config, pkgs, ... }:

let
  hyprDir = "${config.home.homeDirectory}/nixos-dotfiles/config/hypr";
  files = builtins.attrNames (builtins.readDir ../config/hypr);
in

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
    blueman-applet.enable = true;
  };

  programs = {
    hyprshot.enable = true;
    waybar.enable = true;
    hyprlock.enable = true;
  };

  home.packages = with pkgs; [
    nautilus
    brightnessctl
  ];

  xdg.configFile = builtins.listToAttrs (map (f: {
    name = "hypr/${f}";
    value.source = config.lib.file.mkOutOfStoreSymlink "${hyprDir}/${f}";
  }) files);
}
