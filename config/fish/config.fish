# ~/.config/fish/config.fish: DO NOT EDIT -- this file has been generated
# automatically by home-manager.

# Only execute this file once per shell.
# set -q __fish_home_manager_config_sourced; and exit
# set -g __fish_home_manager_config_sourced 1

# source /nix/store/85jcp4jrs1nmpj3i4yljpjv8vda2pr8g-hm-session-vars.fish/etc/profile.d/hm-session-vars.fish

# Source handler functions
source $XDG_CONFIG_HOME/fish/functions/__notify_long_cmd_preexec.fish
source $XDG_CONFIG_HOME/fish/functions/__notify_long_cmd.fish
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

if status is-login
    # Source /etc/profile on login. Copied from https://wiki.archlinux.org/title/Fish#Source_/etc/profile_on_login
    if not set -q __sourced_profile
        set -x __sourced_profile 1
        exec bash -c "\
            test -e /etc/profile && source /etc/profile
            test -e $HOME/.bash_profile && source $HOME/.bash_profile
            exec fish --login
        "
    end
    set -e __sourced_profile

    # put your other configs below

end

if status is-interactive
    # Interactive shell initialisation
    if test "$TERM" = xterm-kitty
        # Run fastfetch only when term is kitty (that means exclude vscode, ides, ...)
        fastfetch
    end
end

# Append common directories for executable files to $PATH
fish_add_path ~/.local/bin ~/.cargo/bin ~/Applications/depot_tools

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"


# Abbreviations
abbr --add -- .. 'cd ..'
abbr --add -- ... 'cd ../..'
abbr --add -- .... 'cd ../../..'

abbr --add -- ls 'eza'
abbr --add -- la 'eza -a'
abbr --add -- ll 'eza -lh'
abbr --add -- lla 'eza -lha'
abbr --add -- lt 'eza --tree'

# Sort installed packages according to size in MB
abbr --add -- big "expac -H M '%m\t%n' | sort -h | nl"
# List amount of -git packages
abbr --add -- gitpkg 'pacman -Q | grep -i "\-git" | wc -l'
abbr --add -- update 'sudo cachyos-rate-mirrors && sudo pacman -Syu'
# Get fastest mirrors
abbr --add -- mirror 'sudo cachyos-rate-mirrors'
# Cleanup orphaned packages
abbr --add -- cleanup 'sudo pacman -Rns (pacman -Qtdq)'
# Recent installed packages
abbr --add -- rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

abbr --add -- grep 'grep --color=auto'
abbr --add -- egrep 'grep -E --color=auto'
abbr --add -- fgrep 'grep -F --color=auto'
abbr --add -- hw 'hwinfo --short'   # Hardware Info
abbr --add -- jctl 'journalctl -p 3 -xb'
abbr --add -- history "history --show-time='%F %T '"
abbr --add -- tarnow 'tar -acf'
abbr --add -- untar 'tar -zxvf'

# Aliases
alias eza 'eza --icons=always --color=always --group-directories-first --header'

set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock
