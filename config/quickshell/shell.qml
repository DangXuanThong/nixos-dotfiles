import Quickshell
import QtQuick
import "modules/battery"
import "modules/wifi"
import "modules/clock"
import "modules/speaker"
import "modules/bluetooth"

ShellRoot {
    PanelWindow {   // qmllint disable uncreatable-type
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 120
        exclusiveZone: bar.barHeight
        color: "transparent"
        mask: Region { item: bar }

        Item {
            id: bar

            readonly property double barHeight: 28

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: barHeight

            Clock {}

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 16
                rightPadding: 8
                spacing: 8

                BluetoothIcon {
                    height: parent.height
                }
                SpeakerIcon {
                    height: parent.height
                }
                WifiIcon {
                    height: parent.height
                }
                BatteryIcon {
                    height: parent.height
                }
            }
        }
    }
}
