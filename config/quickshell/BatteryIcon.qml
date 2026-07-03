import Quickshell.Services.UPower

StatusIcon {
    property var battery: UPower.displayDevice

    text: "\uf240"

    function formatDuration(seconds) {
        if (seconds <= 0) return "";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? (h + "h " + m + "m") : (m + "m");
    }

    tooltipText: {
        if (!battery.ready) return "Loading…";

        var pct = Math.round(battery.percentage * 100) + "%";
        if (battery.state === UPowerDeviceState.Charging) {
            var t = formatDuration(battery.timeToFull);
            return pct + (t ? " • " + t + " until full" : "");
        } else if (battery.state === UPowerDeviceState.Discharging) {
            var t = formatDuration(battery.timeToEmpty);
            return pct + (t ? " • " + t + " left" : "");
        } else if (battery.state === UPowerDeviceState.FullyCharged) {
            return pct + " • Fully charged";
        }
        return pct;
    }
}
