import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property double sourceWidth: 24
    property double sourceHeight: 24
    property alias fillColor: shapePath.fillColor
    property alias svgPath: pathSvg.path
    property alias fillRule: shapePath.fillRule

    readonly property double scaleFactor: Math.min(width / sourceWidth, height / sourceHeight)

    implicitWidth: sourceWidth
    implicitHeight: sourceHeight

    Shape {
        width: root.sourceWidth
        height: root.sourceHeight
        anchors.centerIn: parent
        transform: Scale {
            xScale: root.scaleFactor
            yScale: root.scaleFactor
            origin.x: root.sourceWidth / 2
            origin.y: root.sourceHeight / 2
        }
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath
            fillColor: "black"
            strokeWidth: -1
            PathSvg { id: pathSvg }
        }
    }
}
