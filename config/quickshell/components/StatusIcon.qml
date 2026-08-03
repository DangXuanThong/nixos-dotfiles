import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias tooltipText: toolTip.text

    HoverHandler {
        id: hover
    }

    ToolTip {
        id: toolTip
        visible: hover.hovered
    }
}
