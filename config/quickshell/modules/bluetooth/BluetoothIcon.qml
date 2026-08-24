import Quickshell.Bluetooth
import QtQuick
import "../../components"

StatusIcon {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter // qmllint disable unresolved-type
    readonly property list<var> connectedDevices: adapter.devices.values.filter(d => d.connected)
    readonly property int bluetoothState: {
        if (!adapter.enabled) return Enums.BluetoothState.DISABLED
        if (connectedDevices.length > 0) return Enums.BluetoothState.CONNECTED
        if (adapter.discovering) return Enums.BluetoothState.SCANNING
        return Enums.BluetoothState.ENABLED
    }

    readonly property double designWidth: 24
    readonly property double designHeight: 24
    readonly property double contentScale: height / designHeight

    property bool darkBackground: true

    visible: bluetoothState !== Enums.BluetoothState.DISABLED
    implicitWidth: designWidth * contentScale
    implicitHeight: designHeight * contentScale

    tooltipText: {
        if (bluetoothState === Enums.BluetoothState.ENABLED) return "On • 0 connected";
        return `On • ${connectedDevices.length} connected\n` +
            connectedDevices.map(d => {
                if (!d.batteryAvailable) return d.name;
                return `${d.name}: ${Math.round(d.battery * 100)}%`;
            }).join("\n");
    }

    QtObject {
        id: colors

        readonly property color fill: root.darkBackground ? "white" : "black"
    }

    BluetoothConnected {
        visible: root.bluetoothState === Enums.BluetoothState.CONNECTED
        fillColor: colors.fill
        anchors.fill: parent
    }
    BluetoothScanning {
        visible: root.bluetoothState === Enums.BluetoothState.SCANNING
        fillColor: colors.fill
        anchors.fill: parent
    }
    BluetoothOn {
        visible: root.bluetoothState === Enums.BluetoothState.ENABLED
        fillColor: colors.fill
        anchors.fill: parent
    }
}
