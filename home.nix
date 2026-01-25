{ config, pkgs, ... }:

{
  home.username = "penguin";
  home.homeDirectory = "/home/penguin";
  home.shell.enableFishIntegration = true;

  programs = {
    # Gaming
    mangohud.enable = true;
    # Dev
    git = {
      enable = true;
      settings.user.name = "Dang Xuan Thong";
      settings.user.email = "dangxuanthongvn@gmail.com";
    };
    java = {
      enable = true;
      package = pkgs.jdk25;
    };
    vscode.enable = true;
    # Other
    fish = {
      enable = true;
      shellAliases = {
        nix-rebuild = "sudo nixos-rebuild switch --flake ~/.config/nixos-dotfiles --impure";
      };
    };
    ghostty.enableFishIntegration = true;
    firefox.enable = true;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch
    bat
    eza
    kdePackages.kate
    flameshot
    jetbrains.idea
    prismlauncher
    jetbrains.idea
    flameshot
    jetbrains.datagrip
    jetbrains-runner
    nodejs
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
