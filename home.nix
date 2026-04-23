{ lib, config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Standard .config/directory
  configs = {
    MangoHud = "MangoHud";
    ghostty = "ghostty";
  };
in

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./modules/fish.nix
    ./modules/flatpak.nix
    ./modules/android-studio.nix
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
    brave = {
      enable = true;
      extensions = [
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
        { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # gg translate
        { id = "bgnkhhnnamicmpeenaelnjfhikgbkllg"; } # adguard
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
        { id = "icallnadddjmdinamnolclfjanhfoafe"; } # fast forward
      ];
      package = pkgs.brave;
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Gaming
    prismlauncher
    protonplus
    # Dev
    jetbrains.idea
    python314
    nodejs
    genymotion
    flutter
    # Other
    kdePackages.kate
    flameshot
    jetbrains-runner
    kdePackages.filelight
    inkscape
  ];

  # Iterate over xdg configs and map them accordingly
  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  home.activation.flutterSymlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn ${pkgs.flutter} $HOME/flutter
  '';
}
