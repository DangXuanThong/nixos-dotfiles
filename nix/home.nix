{ config, pkgs, ... }:

{
  home.username = "penguin";
  home.homeDirectory = "/home/penguin";

  # Import files from the current configuration directory into the Nix store,
  # and create symbolic links pointing to those store files in the Home directory.
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # Import the scripts directory into the Nix store,
  # and recursively generate symbolic links in the Home directory pointing to the files in the store.
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  programs = {
    git = {
      enable = true;
      settings.user.name = "Dang Xuan Thong";
      settings.user.email = "dangxuanthongvn@gmail.com";
    };
    firefox.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk25;
    };
    mangohud.enable = true;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    kdePackages.kate
    flameshot
    jetbrains.idea
    prismlauncher
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
}
