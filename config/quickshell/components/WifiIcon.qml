import Quickshell.Networking
import QtQuick

StatusIcon {
    Text {
        text: "\uf1eb"
        color: "#ffffff"
        font.pixelSize: 13
        font.family: "JetBrainsMono Nerd Font"
        renderType: Text.NativeRendering
    }

    function activeWifiNetwork() {
        var devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            var dev = devices[i];
            if (dev.type === DeviceType.Wifi && dev.connected) {
                var nets = dev.networks.values;
                for (var j = 0; j < nets.length; j++) {
                    if (nets[j].connected) return nets[j];
                }
            }
        }
        return null;
    }

    tooltipText: {
        var net = activeWifiNetwork();
        return net ? (net.name + " • " + Math.round(net.signalStrength * 100) + "%") : "Not connected";
    }
}