function __format_duration
    set -l total_ms $argv[1]
    set -l total_secs (math --scale=0 "floor($total_ms / 1000)")

    set -l hours (math --scale=0 "floor($total_secs / 3600)")
    set -l rem (math --scale=0 "$total_secs - ($hours * 3600)")
    set -l minutes (math --scale=0 "floor($rem / 60)")
    set -l seconds (math --scale=0 "$rem - ($minutes * 60)")

    set -l parts
    if test $hours -gt 0
        set -a parts "$hours"h
    end
    if test $minutes -gt 0
        set -a parts "$minutes"m
    end
    if test $seconds -gt 0
        set -a parts "$seconds"s
    end

    string join " " $parts
end

function __truncate_cmd_display
    set -l cmd $argv[1]
    set -l max_chars 60

    # collapse to first line if it's an actual multi-line command
    set -l first_line (string split -m1 -- \n $cmd)[1]

    set -l was_truncated 0
    if test "$first_line" != "$cmd"
        set was_truncated 1
    end

    # cap length even for a long single-line command
    if test (string length -- "$first_line") -gt $max_chars
        set first_line (string sub -l $max_chars -- $first_line)
        set was_truncated 1
    end

    if test $was_truncated -eq 1
        echo "$first_line…"
    else
        echo "$first_line"
    end
end

if test -n "$CMD_DURATION"; and test $CMD_DURATION -gt 5000
    set -l current_pid (hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty')

    if test -n "$__notify_focused_pid"; and test "$current_pid" != "$__notify_focused_pid"
        set -l exit_status $status
        set -l finish_time (date +%H:%M:%S)
        set -l display_cmd (__truncate_cmd_display $argv[1])
        set -l safe_cmd (string replace -a "&" "&amp;" $display_cmd | string replace -a "<" "&lt;" | string replace -a ">" "&gt;")
        set -l duration_str (__format_duration $CMD_DURATION)

        notify-send \
            -a "$__notify_win_class" \
            -i "$__notify_win_class" \
            "Command finished · $finish_time" \
            "<tt>$safe_cmd</tt>\nexecuted in $duration_str and returned $exit_status"
    end
end
