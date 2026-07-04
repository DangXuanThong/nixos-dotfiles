import Quickshell.Services.UPower
import QtQuick

StatusIcon {
    id: batteryRoot

    property var battery: UPower.displayDevice
    property real pct: battery.ready ? battery.percentage : 0
    property bool charging: battery.ready &&
        battery.state === UPowerDeviceState.Charging ||
        (battery.state === UPowerDeviceState.FullyCharged && pct === 1.0)
    property bool protectedCharge: battery.ready && battery.state === UPowerDeviceState.FullyCharged && pct < 1.0
    property bool powerSaverActive: PowerProfiles.profile === PowerProfile.PowerSaver

    function formatDuration(seconds) {
        if (seconds <= 0) return "";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? (h + "h " + m + "m") : (m + "m");
    }

    tooltipText: {
        if (!battery.ready) return "Loading…";

        var pctText = Math.round(battery.percentage * 100) + "%";
        if (battery.state === UPowerDeviceState.Charging) {
            var t = formatDuration(battery.timeToFull);
            return pctText + (t ? " • " + t + " until full" : "");
        } else if (battery.state === UPowerDeviceState.Discharging) {
            var t = formatDuration(battery.timeToEmpty);
            return pctText + (t ? " • " + t + " left" : "");
        } else if (battery.state === UPowerDeviceState.FullyCharged) {
            return pctText + " • Fully charged";
        }
        return pctText;
    }

    Item {
        width: 25
        height: 15

        Image {
            source: "../assets/battery_bg.svg"
            sourceSize.width: 25
            sourceSize.height: 15
            width: 25
            height: 15
        }

        Item {
            id: fillClip
            x: 24 - width
            y: 1
            width: 21 * Math.max(batteryRoot.pct, batteryRoot.pct > 0 ? 0.08 : 0)
            height: 13
            clip: true

            Image {
                x: -(21 - fillClip.width)
                source: "../assets/battery_fill.svg"
                sourceSize.width: 21
                sourceSize.height: 13
                width: 21
                height: 13
            }
        }

        Image {
            visible: batteryRoot.charging
            source: "../assets/charging.svg"
            sourceSize.width: 8
            sourceSize.height: 10
            width: 8
            height: 10
            x: 9.25
            y: 2.25
        }

        Image {
            visible: batteryRoot.protectedCharge
            source: "../assets/protected.svg"
            sourceSize.width: 8
            sourceSize.height: 9
            width: 8
            height: 9
            x: 9.55
            y: 2.75
        }

        Image {
            visible: batteryRoot.powerSaverActive && !batteryRoot.charging && !batteryRoot.protectedCharge
            source: "../assets/powersave.svg"
            sourceSize.width: 8
            sourceSize.height: 9
            width: 8
            height: 9
            x: 9.25
            y: 3.25
        }
    }
}
