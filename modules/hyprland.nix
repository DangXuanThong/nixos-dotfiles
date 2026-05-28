{ config, lib, pkgs, ... }:

let
  home = config.home.homeDirectory;
  configDir = "${home}/nixos-dotfiles/config";
  mkConfigEntries = names:
    builtins.concatMap (folder:
      let
        files = builtins.attrNames (
          lib.filterAttrs (_: v: v == "regular") (builtins.readDir (../config + "/${folder}"))
        );
      in
      map (f: {
        name = "${folder}/${f}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${configDir}/${folder}/${f}";
      }) files
    ) names;
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
    sublime3
    grim
    slurp
    wl-clipboard
  ];

  xdg.configFile = builtins.listToAttrs (mkConfigEntries [ "hypr" "waybar" ]);

  home.activation.buildHyprcursor = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rm -rf ${home}/.icons/theme_MacOS\ Tahoe\ Cursor
    nix-shell -p hyprcursor --run "hyprcursor-util --create ${home}/nixos-dotfiles/config/cursor/MacTahoeCursor --output ${home}/.icons"
    rm -rf ${home}/.icons/MacTahoeCursor
    mv ${home}/.icons/theme_MacOS\ Tahoe\ Cursor ${home}/.icons/MacTahoeCursor
  '';
}
