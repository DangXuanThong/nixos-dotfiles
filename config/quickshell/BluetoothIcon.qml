import Quickshell.Bluetooth

StatusIcon {
    text: "\uf293"

    tooltipText: {
        var enabled = Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled;
        var count = Bluetooth.devices.values.length;
        return enabled ? ("On • " + count + " connected") : "Off";
    }
}
