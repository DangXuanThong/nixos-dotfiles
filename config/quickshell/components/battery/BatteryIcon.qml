import Quickshell.Services.UPower
import QtQuick
import "../"

StatusIcon {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property int level: device.percentage * 100
    readonly property int batteryState: {
        if (!device.ready) return Enums.BatteryState.UNKNOWN
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return Enums.BatteryState.POWERSAVE

        switch (device.state) {
        case UPowerDeviceState.Charging:
            return Enums.BatteryState.CHARGING
        case UPowerDeviceState.FullyCharged:
            return level < 100 ? Enums.BatteryState.PROTECTED : Enums.BatteryState.CHARGING
        case UPowerDeviceState.Unknown:
            return Enums.BatteryState.UNKNOWN
        default:
            return Enums.BatteryState.DEFAULT
        }
    }
    readonly property int criticalThreshold: 20
    readonly property bool isCritical: level <= criticalThreshold
    readonly property bool darkBackground: true

    function formatDuration(seconds) {
        if (seconds <= 0) return ""
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        return h > 0 ? (h + "h " + m + "m") : (m + "m")
    }

    tooltipText: {
        const pctText = level + '%'
        switch (batteryState) {
            case Enums.BatteryState.CHARGING:
                var t = formatDuration(device.timeToFull);
                return pctText + (t ? " • " + t + " until full" : " • Fully charged");
            case Enums.BatteryState.PROTECTED:
                return pctText + " • Fully charged";
            case Enums.BatteryState.UNKNOWN:
                return "Loading…"
            default:
                var t = formatDuration(device.timeToEmpty);
                return pctText + (t ? " • " + t + " left" : "");
        }
    }

    QtObject {
        id: colors

        readonly property color background: {
            if (!root.darkBackground) return Qt.rgba(0, 0, 0, 0.2);
            else return root.batteryState === Enums.BatteryState.DEFAULT ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.55);
        }

        readonly property color fill: {
            switch (root.batteryState) {
                case Enums.BatteryState.CHARGING:
                case Enums.BatteryState.PROTECTED:
                    return "#18cc48";
                case Enums.BatteryState.POWERSAVE:
                    return "#FFC917";
                default:
                    if (root.batteryState === Enums.BatteryState.DEFAULT && root.isCritical) return "#FF0E01";
                    return root.darkBackground ? "white" : "black";
            }
        }

        readonly property color attributionColor: root.darkBackground ? "white" : "black"
    }

    Item {
        implicitWidth: 30.8
        implicitHeight: 13

        Frame {
            batteryState: root.batteryState
            level: root.level
            anchors.verticalCenter: parent.verticalCenter
            backgroundColor: colors.background
            fillColor: colors.fill
        }

        // ---- Plain cap (only drawn when no attribution glyph is active) ----
        Cap {
            visible: root.batteryState === Enums.BatteryState.DEFAULT
            x: 25
            anchors.verticalCenter: parent.verticalCenter
            fillColor: colors.attributionColor
            opacity: root.level === 100 ? 1.0 : 0.45
        }

        // ---- Attribution glyph (replaces the cap, overlaps shell 20%) ------
        Glyph {
            id: glyph
            batteryState: root.batteryState
            visible: root.batteryState !== Enums.BatteryState.DEFAULT
            x: (24 - glyph.activeGlyph.w * 0.2)
            anchors.verticalCenter: parent.verticalCenter
            fillColor: colors.attributionColor
        }
    }
}
