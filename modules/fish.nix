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
      
      grep = "grep --color=auto";
      fgrep = "grep -F --color=auto";
      egrep = "grep -E --color=auto";
      jctl = "journalctl -p 3 -xb";  # Get the error messages from journalctl
      history = "history --show-time='%F %T '";

      nixswitch = "clear && nh os switch --impure";
      nixupdate = "clear && nh os switch --update --impure";
      nixclean = "clear && nh clean all --keep 5 --optimise";
    };
    interactiveShellInit = ''
      if test "$TERM" = "xterm-kitty"
          fastfetch
      end
    '';
    functions = {
      backup.body = "cp $filename $filename.bak";
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
