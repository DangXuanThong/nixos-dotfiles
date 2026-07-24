import Quickshell
import QtQuick
import "components"
import "components/battery"

ShellRoot {
    PanelWindow {   // qmllint disable uncreatable-type
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

                BluetoothIcon {
                    anchors.verticalCenter: parent.verticalCenter
                }
                WifiIcon {
                    anchors.verticalCenter: parent.verticalCenter
                }
                SpeakerIcon {
                    anchors.verticalCenter: parent.verticalCenter
                }
                BatteryIcon {
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
