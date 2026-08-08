import QtQuick
import QtQuick.Shapes

Item {
    id: root
    implicitWidth: sourceWidth
    implicitHeight: sourceHeight

    readonly property real sourceWidth: 24
    readonly property real sourceHeight: 24
    property alias color: path.fillColor
    property int fillMode: Image.PreserveAspectFit

    readonly property real uniformScale: fillMode === Image.PreserveAspectCrop
        ? Math.max(width / sourceWidth, height / sourceHeight)
        : Math.min(width / sourceWidth, height / sourceHeight)

    clip: fillMode === Image.PreserveAspectCrop

    Shape {
        width: root.sourceWidth
        height: root.sourceHeight
        anchors.centerIn: parent
        clip: true
        transform: Scale { xScale: root.uniformScale; yScale: root.uniformScale }
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: path
            fillColor: "black"
            strokeColor: "transparent"
            strokeWidth: -1
            PathSvg { path: "M12 2L2 7l10 5 10-5-10-5z" }
        }
    }
}
