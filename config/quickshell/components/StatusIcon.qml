import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property string tooltipText

    width: childrenRect.width
    height: childrenRect.height

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
