import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 28
        color: "transparent"

        Text {
            id: clock

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1.5
            leftPadding: 12
            rightPadding: 12

            color: "#ffffff"
            font.pixelSize: 13
            renderType: Text.NativeRendering

            property date currentTime: new Date()

            text: Qt.formatDateTime(currentTime, "hh:mm ddd d MMM")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.currentTime = new Date()
            }
        }
    }
}
