import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 120
        exclusiveZone: 28
        color: "transparent"
        mask: Region { item: bar }

        Item {
            id: bar

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28

            Clock {}

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1.5
                rightPadding: 12
                spacing: 12

                BluetoothIcon {}
                WifiIcon {}
                SpeakerIcon {}
                BatteryIcon {}
            }
        }
    }
}
