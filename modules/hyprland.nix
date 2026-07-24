{ config, lib, pkgs, ... }:

let
  mkConfigLink = import ../lib/mkConfigLink.nix {
    inherit config lib;
  };
in

{
  imports = [ ./cursor.nix ];

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
    quickshell = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };
    hyprshot.enable = true;
    hyprlock.enable = true;
  };

  home.packages = with pkgs; [
    # Applications
    nautilus
    obs-studio
    loupe
    celluloid
    gnome-text-editor
    mission-center
    file-roller
    # Utils
    brightnessctl
    grim
    slurp
    wl-clipboard
    dunst
    networkmanagerapplet
  ];

  xdg.configFile = lib.mkMerge [
    (mkConfigLink "hypr/binds.lua")
    (mkConfigLink "hypr/hyprland.lua")
    (mkConfigLink "hypr/hyprpaper.conf")
    (mkConfigLink "hypr/inputs.lua")
    (mkConfigLink "hypr/monitors.lua")
    (mkConfigLink "hypr/permissions.lua")
    (mkConfigLink "hypr/rules.lua")

    (mkConfigLink "quickshell")
  ];
  systemd.user = {
    timers = {
      dark-mode = {
        Timer = {
          OnCalendar = "*-*-* 17:00:00"; # switch to dark at 5PM
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
      light-mode = {
        Timer = {
          OnCalendar = "*-*-* 06:00:00"; # switch to light at 6AM
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
    services = {
      dark-mode = {
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "dark-mode" ''
            dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
          '');
        };
      };
      light-mode = {
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "light-mode" ''
            dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
          '');
        };
      };
    };
  };
}
