{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;
    settings = {
      mod = {
        _var = "SUPER";
      };
    };
  };

  services = {
    hyprpolkitagent.enable = true;
    hypridle.enable = true;
    hyprpaper.enable = true;
  };

  programs = {
    hyprshot.enable = true;
    waybar.enable = true;
  };

  home.packages = with pkgs; [
    nautilus
  ];
}
