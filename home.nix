{ lib, config, pkgs, ... }:

let
  mkConfigLink = import lib/mkConfigLink.nix {
    inherit config lib;
  };
in

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./modules/fish.nix
    ./modules/flatpak.nix
    ./modules/android-studio.nix
    ./modules/hyprland.nix
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
  home.username = "penguin";
  home.homeDirectory = "/home/penguin";

  programs = {
    # Gaming
    mangohud.enable = true;
    # Dev
    git = {
      enable = true;
      settings = {
        user.name = "Dang Xuan Thong";
        user.email = "dangxuanthongvn@gmail.com";
        init.defaultBranch = "main";
      };
    };
    java = {
      enable = true;
      package = pkgs.jdk25;
    };
    vscode.enable = true;
    # Other
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Gaming
    prismlauncher
    protonplus
    heroic
    ryubing # nintendo switch emulator (.nsp)
    azahar # 3ds emulator (.3ds)
    # Dev
    jetbrains.idea
    python314
    nodejs
    genymotion
    flutter
    # Other
    kdePackages.filelight
    onlyoffice-desktopeditors
    kdePackages.qtdeclarative
  ];

  nixpkgs.overlays = [
    # Skipping tests while upstream sorts it out, revert once
    # Hydra consistently builds openldap green.
    (import ./overlays/genymotion.nix)
  ];

  xdg.configFile = lib.mkMerge [
    (mkConfigLink "MangoHud")
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  home.activation.flutterSymlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn ${pkgs.flutter} $HOME/flutter
  '';
}
