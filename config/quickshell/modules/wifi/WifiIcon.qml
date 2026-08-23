import Quickshell.Networking
import QtQuick
import "../../components"

StatusIcon {
    id: root

    readonly property bool isEthernetConnected: {
        const devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wired && devices[i].connected) return true;
        }
        return false;
    }

    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi) return devices[i];
        }
        return null;
    }
    readonly property bool isWifiEnabled: wifiDevice && Networking.wifiEnabled && Networking.wifiHardwareEnabled
    readonly property var connectedNetwork: {
        if (!isWifiEnabled) return null;
        const networks = wifiDevice.networks.values;
        for (var i = 0; i < networks.length; i++) {
            if (networks[i].state === ConnectionState.Connected) return networks[i];
        }
        return null;
    }
    readonly property int strength: connectedNetwork ? Math.round(connectedNetwork.signalStrength * 100) : -1
    readonly property bool hasInternetAccess: connectedNetwork &&
        Networking.connectivity !== NetworkConnectivity.Limited &&
        Networking.connectivity !== NetworkConnectivity.Portal

    property bool darkBackground: true

    readonly property double designWidth: 15
    readonly property double designHeight: 15
    readonly property double contentScale: height / designHeight

    implicitWidth: designWidth * contentScale
    implicitHeight: designHeight * contentScale

    tooltipText: {
        if (isEthernetConnected) return "Ethernet connected";
        if (!isWifiEnabled) return "Off";
        if (!connectedNetwork) return "Not connected";
        const commonTooltip = connectedNetwork.name + " • " + strength + "%";
        if (!hasInternetAccess) return commonTooltip + " • No internet";
        return commonTooltip;
    }

    QtObject {
        id: colors

        readonly property color fill: root.darkBackground ? "white" : "black"
    }

    Item {
        anchors.centerIn: parent
        width: root.designWidth
        height: root.designHeight
        scale: root.contentScale
        transformOrigin: Item.Center

        Wired {
            visible: root.isEthernetConnected
            anchors.fill: parent
            fillColor: colors.fill
        }
        Wireless {
            visible: !root.isEthernetConnected && root.isWifiEnabled
            strength: root.strength
            hasInternetAccess: root.hasInternetAccess
            fillActive: colors.fill
            anchors.fill: parent
        }
        Off {
            visible: !root.isEthernetConnected && !root.isWifiEnabled
            anchors.fill: parent
            fillColor: colors.fill
        }
    }
}
