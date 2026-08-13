import Quickshell.Networking
import QtQuick
import "../../components"

StatusIcon {
    id: wifiRoot

    property bool isEthernetConnected: {
        var devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wired && devices[i].connected) return true;
        }
        return false;
    }

    property var wifiDevice: {
        var devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi) return devices[i];
        }
        return null;
    }
    property bool isWifiEnabled: wifiDevice && Networking.wifiEnabled && Networking.wifiHardwareEnabled
    property var connectedNetwork: {
        if (!isWifiEnabled) return null;
        var networks = wifiDevice.networks.values;
        for (var i = 0; i < networks.length; i++) {
            if (networks[i].state === ConnectionState.Connected) return networks[i];
        }
        return null;
    }
    property bool hasInternetAccess: connectedNetwork &&
        Networking.connectivity !== NetworkConnectivity.Limited &&
        Networking.connectivity !== NetworkConnectivity.Portal
    property bool isPublic: connectedNetwork?.security === WifiSecurityType.Open

    property string iconSource: {
        if (isEthernetConnected) return "ethernet.svg";
        if (!isWifiEnabled) return "wifi_off.svg";
        if (!connectedNetwork) return "wifi_not_connected.svg";
        if (!hasInternetAccess) return "wifi_no_internet.svg";
        var tier = connectedNetwork.signalStrength <= 0.33 ? "weak"
            : connectedNetwork.signalStrength <= 0.66 ? "med"
            : "strong";
        var kind = isPublic ? "public" : "private";
        return "wifi_" + kind + "_" + tier + ".svg";
    }

    Image {
        source: wifiRoot.iconSource
        sourceSize.width: 16
        sourceSize.height: 16
        width: 16
        height: 16
    }

    tooltipText: {
        if (isEthernetConnected) return "Ethernet connected";
        if (!isWifiEnabled) return "Off";
        if (!connectedNetwork) return "Not connected";
        var strength = Math.round(connectedNetwork.signalStrength * 100) + "%";
        if (!hasInternetAccess) return connectedNetwork.name + " • " + strength + " • No internet";
        return connectedNetwork.name + " • " + strength;
    }
}
