# Raise notification after long-running command completes (pre hook, see __notify_long_cmd.fish)
function __notify_long_cmd_preexec --on-event="fish_preexec"
    set -l win_info (hyprctl activewindow -j 2>/dev/null)
    set -g __notify_focused_pid (echo $win_info | jq -r '.pid // empty')
    set -g __notify_win_class (echo $win_info | jq -r '.class // empty')
end
