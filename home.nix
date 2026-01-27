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
        # Replace ls with eza
        ls = "eza -al --color=always --group-directories-first --icons"; # preferred listing
        la = "eza -a --color=always --group-directories-first --icons";  # all files and dirs
        ll = "eza -l --color=always --group-directories-first --icons";  # long format
        lt = "eza -aT --color=always --group-directories-first --icons"; # tree listing
        "l." = "eza -a | grep -e '^.'";                                  # show only dotfiles
        # Common use
        tarnow = "tar -acf ";
        untar = "tar -zxvf ";
        psmem = "ps auxf | sort -nr -k 4";
        psmem10 = "ps auxf | sort -nr -k 4 | head -10";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";
        dir = "dir --color=auto";
        vdir = "vdir --color=auto";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        jctl = "journalctl -p 3 -xb";   # Get the error messages from journalctl

        nix-rebuild = "sudo nixos-rebuild switch --flake ~/.config/nixos-dotfiles --impure";
      };
      shellInit = ''
        # Format man pages
        set -x MANROFFOPT "-c"
        set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

        # Set settings for https://github.com/franciscolourenco/done
        set -U __done_min_cmd_duration 10000
        set -U __done_notification_urgency_level low

        ## Environment setup
        # Apply .profile: use this to put fish compatible .profile stuff in
        if test -f ~/.fish_profile
          source ~/.fish_profile
        end

        # Add ~/.local/bin to PATH
        if test -d ~/.local/bin
            if not contains -- ~/.local/bin $PATH
                set -p PATH ~/.local/bin
            end
        end

        # Add depot_tools to PATH
        if test -d ~/Applications/depot_tools
            if not contains -- ~/Applications/depot_tools $PATH
                set -p PATH ~/Applications/depot_tools
            end
        end
      '';
      interactiveShellInit = ''
        ## Run fastfetch as welcome message
        function fish_greeting
            fastfetch
        end
      '';
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

  # home.file = {
  #   # Fish config
  #   ".config/fish" = {
  #     source = ../config/fish;
  #     recursive = true;
  #   };

  #   # MangoHud config
  #   ".config/MangoHud".source = ../config/MangoHud;
  # };

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
