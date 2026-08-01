{ config, lib, pkgs, ...}:

let
  mkConfigLink = import ../lib/mkConfigLink.nix {
    inherit config lib;
  };
in

{
  home.shell.enableFishIntegration = true;
  home.sessionVariables = {
    # Format man pages
    MANROFFOPT = "-c";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      tarnow = "tar -acf ";
      untar = "tar -zxvf ";
      wget = "wget -c ";
      
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      jctl = "journalctl -p 3 -xb";  # Get the error messages from journalctl
      past = "history --show-time='%F %T '";
    };
    shellAliases = {
      nix-rebuild = "clear && sudo nixos-rebuild switch --impure";
      nix-update = "clear && nix flake update --flake ~/nixos-dotfiles && sudo nixos-rebuild switch --impure";
      nix-cleanup = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-collect-garbage";
    };
    interactiveShellInit = ''
      function fish_greeting
        if test "$TERM" = "xterm-kitty"
          fastfetch
        end
      end
    '';
    shellInitLast = ''
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
      backup.body = "cp $filename $filename.bak";
      # Copy DIR1 DIR2
      copy.body = ''
        set count (count $argv | tr -d \n)
        if test "$count" = 2; and test -d "$argv[1]"
          set from (echo $argv[1] | trim-right /)
          set to (echo $argv[2])
          command cp -r $from $to
        else
          command cp $argv
        end
      '';
      __notify_long_cmd_preexec = {
        body = ''
          set -l win_info (hyprctl activewindow -j 2>/dev/null)
          set -g __notify_focused_pid (echo $win_info | jq -r '.pid // empty')
          set -g __notify_win_class (echo $win_info | jq -r '.class // empty')
        '';
        onEvent = "fish_preexec";
      };
      __notify_long_cmd = {
        body = builtins.readFile ../config/fish/functions/notify_long_cmd.fish;
        onEvent = "fish_postexec";
      };
    };
    plugins = with pkgs.fishPlugins; [
      { name = "bang-bang"; src = bang-bang.src; }
    ];
  };
  programs.ghostty.enableFishIntegration = true;
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--short-nix"
    ];
    icons = "always";
    colors = "always";
  };

  home.packages = with pkgs; [
    fastfetch
    bat
    jq
    libnotify
  ];

  xdg.configFile = lib.mkMerge [
    (mkConfigLink "fastfetch")
  ];
}
