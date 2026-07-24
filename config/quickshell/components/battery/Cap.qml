import QtQuick
import QtQuick.Shapes

Shape {
    property color fillColor: "white"

    id: root
    width: 1.5
    height: 6.0234
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.fillColor
        strokeWidth: -1
        PathSvg { path: "M0.3333,-0.0037L0,-0.0037L0,6.0234L0.3333,6.0234C0.9777,6.0234 1.5,5.5011 1.5,4.8567L1.5,1.163C1.5,0.5187 0.9777,-0.0037 0.3333,-0.0037Z" }
    }
}
