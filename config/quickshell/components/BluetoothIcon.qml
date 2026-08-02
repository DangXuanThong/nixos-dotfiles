import Quickshell.Bluetooth
import QtQuick

StatusIcon {
    implicitWidth: 24
    implicitHeight: 24

    Text {
        text: "\uf293"
        color: "#ffffff"
        font.pixelSize: 13
        font.family: "JetBrainsMono Nerd Font"
        renderType: Text.NativeRendering
    }

    tooltipText: {
        var enabled = Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled;
        var count = Bluetooth.devices.values.length;
        return enabled ? ("On • " + count + " connected") : "Off";
    }
}
