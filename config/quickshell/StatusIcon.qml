import QtQuick
import QtQuick.Controls

Text {
    id: root

    property string tooltipText: ""

    color: "#ffffff"
    font.pixelSize: 13
    font.family: "JetBrainsMono Nerd Font"
    renderType: Text.NativeRendering

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
    }

    ToolTip {
        visible: area.containsMouse
        text: root.tooltipText
        y: root.height + 4
    }
}
