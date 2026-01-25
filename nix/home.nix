{ config, pkgs, ... }:

{
  home.username = "penguin";
  home.homeDirectory = "/home/penguin";

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
    prismlauncher
    jetbrains.idea
    flameshot
  ];

  home.file = {
    # Fish config
    ".config/fish" = {
      source = ../config/fish;
      recursive = true;
    };

    # MangoHud config
    ".config/MangoHud".source = ../config/MangoHud;
  };

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
