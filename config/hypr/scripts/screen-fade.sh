#!/usr/bin/env bash
# Fade the monitor backlight in (fast) or out (slow).

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/screen_brightness_old_value"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/screen_brightness_fade.pid"
MAX=$(brightnessctl max)

# Cancel whatever fade is currently in flight so overlapping in/out
# calls can't race each other and leave the brightness stuck mid-fade.
if [ -f "$PID_FILE" ]; then
    old_pid="$(cat "$PID_FILE")"

    if [ -n "$old_pid" ] && [ "$old_pid" != "$$" ] && kill -0 "$old_pid" 2>/dev/null; then
        kill "$old_pid" 2>/dev/null
    fi
fi
echo $$ > "$PID_FILE"


fade() {
    local from="$1" to="$2" duration_ms="$3"
    local fps=30
    local steps=$(( (duration_ms * fps + 999) / 1000 ))

    (( steps < 1 )) && steps=1

    mapfile -t values < <(
        awk \
            -v from="$from" \
            -v to="$to" \
            -v steps="$steps" '
        BEGIN {
            pi = atan2(0,-1)

            for (i = 1; i <= steps; i++) {
                t = i / steps

                # ease-in-out cosine
                easing = (1 - cos(pi * t)) / 2

                value = from + (to - from) * easing

                printf "%.0f\n", value
            }
        }'
    )

    duration_us=$((duration_ms * 1000))
    frame0_us=${EPOCHREALTIME/[^0-9]/}
    for ((i=0; i<steps; i++)); do
        brightnessctl -q set "${values[i]}"

        target_us=$(( frame0_us + ((i + 1) * duration_us) / steps ))
        now_us=${EPOCHREALTIME/[^0-9]/}
        remaining_us=$(( target_us - now_us ))

        if (( remaining_us > 0 )); then
            printf -v sleep_time "%.6f" "${remaining_us}e-6"
            sleep "$sleep_time"
        fi
    done
}


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 in|out <duration_ms>"
    exit 1
fi

current=$(brightnessctl get)
duration=$2
case "$1" in
    out)
        echo "$current" > "$STATE_FILE"
        fade "$current" $(( MAX / 10 )) "$2"    # 10% of MAX brightness
        ;;

    in)
        target="$MAX"
        [ -f "$STATE_FILE" ] && target="$(cat "$STATE_FILE")"
        fade "$current" "$target" "$2"
        ;;

    *)
        echo "Usage: $0 in|out <duration_ms>"
        exit 1
        ;;
esac
