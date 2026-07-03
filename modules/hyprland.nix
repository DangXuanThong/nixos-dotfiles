{ config, lib, pkgs, ... }:

let
  home = config.home.homeDirectory;
  configDir = "${home}/nixos-dotfiles/config";
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

  # xdg.configFile = builtins.listToAttrs (mkConfigEntries [ "hypr" ]);
  xdg.configFile = {
    "hypr/binds.lua".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/binds.lua";
    "hypr/hyprland.lua".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/hyprland.lua";
    "hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/hyprpaper.conf";
    "hypr/inputs.lua".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/inputs.lua";
    "hypr/monitors.lua".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/monitors.lua";
    "hypr/permissions.lua".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/permissions.lua";
    "hypr/rules.lua".source = config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/rules.lua";

    "quickshell" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDir}/quickshell";
      recursive = true;
    };
  };
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
