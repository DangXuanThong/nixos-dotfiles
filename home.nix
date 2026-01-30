{ config, pkgs, ... }:

{
  home.username = "penguin";
  home.homeDirectory = "/home/penguin";
  home.shell.enableFishIntegration = true;
  home.sessionVariables = {
    # Format man pages
    MANROFFOPT = "-c";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

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
        ls = "eza -al --color=always --group-directories-first --icons"; # preferred listing
        la = "eza -a --color=always --group-directories-first --icons";  # all files and dirs
        ll = "eza -l --color=always --group-directories-first --icons";  # long format
        lt = "eza -aT --color=always --group-directories-first --icons"; # tree listing
        "l." = "eza -a | grep -e '^\\.'";                                # show only dotfiles

        tarnow = "tar -acf ";
        untar = "tar -zxvf ";
        wget = "wget -c ";
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
        jctl = "journalctl -p 3 -xb";  # Get the error messages from journalctl

        nix-rebuild = "sudo nixos-rebuild switch --flake ~/.config/nixos-dotfiles --impure";
      };
      interactiveShellInit = ''
        function fish_greeting
          fastfetch
        end
      '';
      shellInitLast = ''
        # Set settings for https://github.com/franciscolourenco/done
        set -U __done_min_cmd_duration 10000
        set -U __done_notification_urgency_level low
        # Workaround for variables interpolation not work with default command on NixOS
        set -U __done_notification_command "notify-send --hint=int:transient:1 --urgency=\$urgency --icon=\"com.mitchellh.ghostty\" --app-name=fish --expire-time=\$__done_notification_duration \"\$title\" \"\$message\""

        # Add ~/.local/bin to PATH
        if test -d ~/.local/bin
          and not contains -- ~/.local/bin $fish_user_paths
          set -U fish_user_paths ~/.local/bin $fish_user_paths
        end

        # Add depot_tools to PATH
        if test -d ~/Applications/depot_tools
          and not contains -- ~/Applications/depot_tools $fish_user_paths
          set -U fish_user_paths ~/Applications/depot_tools $fish_user_paths
        end
      '';
      functions = {
        backup.body = ''
          function backup --argument filename
            cp $filename $filename.bak
          end
        '';
        # Copy DIR1 DIR2
        copy.body = ''
          function copy
            set count (count $argv | tr -d \n)
            if test "$count" = 2; and test -d "$argv[1]"
              set from (echo $argv[1] | trim-right /)
              set to (echo $argv[2])
              command cp -r $from $to
            else
              command cp $argv
            end
          end
        '';
      };
      plugins = with pkgs.fishPlugins; [
        { name = "done"; src = done.src; }
        { name = "bang-bang"; src = bang-bang.src; }
      ];
    };
    ghostty.enableFishIntegration = true;
    firefox.enable = true;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch
    bat
    eza
    libnotify
    kdePackages.kate
    flameshot
    jetbrains.idea
    prismlauncher
    flameshot
    jetbrains.datagrip
    jetbrains-runner
    nodejs
  ];

  xdg.configFile = {
    "MangoHud".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-dotfiles/config/MangoHud";
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
