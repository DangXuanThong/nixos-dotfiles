import QtQuick
import QtQuick.Shapes

Item {
    required property int batteryState
    required property int level

    readonly property list<string> framePaths: [
        // bolt
        "M20 0C22.1334 0 23.8762 1.67024 23.9932 3.77441L21.7295 6.39746L21.7256 6.40234C21.04 7.20646 21.4997 8.62484 22.7314 8.625H24V9C24 11.2091 22.2091 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // defend
        "M20 0C21.6238 0 23.0197 0.968378 23.6465 2.3584C23.1688 2.57644 22.74 2.74041 22.4473 2.84277C21.7817 3.07364 21.4004 3.7049 21.4004 4.33691V4.35645L21.4014 4.375C21.5084 7.18633 22.5494 9.07594 23.6484 10.2676C23.6836 10.3057 23.7197 10.3423 23.7549 10.3789C23.193 11.9085 21.7244 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // plus
        "M20 0C22.2091 0 24 1.79086 24 4V4.59961H23.2178C22.1685 4.59961 21.3174 5.45072 21.3174 6.5C21.3174 7.55073 22.1699 8.39941 23.2178 8.39941H24V9C24 11.2091 22.2091 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // question
        "M20 0C21.1866 0 22.2518 0.517251 22.9844 1.33789C22.9025 1.39878 22.8228 1.46263 22.7461 1.53027C22.4185 1.8179 22.1227 2.15745 21.9502 2.55859L21.9473 2.56641L21.9443 2.57324C21.7609 3.0194 21.7523 3.49449 21.918 3.94629L21.9229 3.95801C22.0925 4.40328 22.4065 4.76057 22.8457 4.97363L22.8574 4.97949C23.1916 5.13599 23.5833 5.22196 24 5.15039V5.75C23.7745 6.15476 23.6788 6.60185 23.6787 7.05664V7.08789C23.6787 7.47057 23.7976 7.81259 24 8.10059V8.83105C23.6177 9.23559 23.4161 9.74279 23.416 10.3037C23.416 10.5211 23.4452 10.7311 23.5029 10.9307C22.8216 12.1641 21.5088 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // default
        "M4,0L20,0A4,4 0 0 1 24,4L24,9A4,4 0 0 1 20,13L4,13A4,4 0 0 1 0,9L0,4A4,4 0 0 1 4,0Z"
    ]
    readonly property string activeFrame: framePaths[batteryState]

    property color backgroundColor: "gray"
    property color fillColor: "black"
    property color digitColor: "black"

    id: root
    implicitWidth: 24
    implicitHeight: 13

    // background shell
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.backgroundColor
            strokeWidth: -1
            PathSvg { path: root.activeFrame }
        }
    }

    // battery level fill
    Item {
        visible: root.level > 0
        implicitWidth: Math.ceil((root.level / 100) * 24)
        implicitHeight: parent.height
        clip: true

        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: root.fillColor
                strokeWidth: -1
                PathSvg { path: root.activeFrame }
            }
        }
    }

    // percentage
    Digits {
        level: root.level
        digitColor: root.digitColor
        anchors.fill: parent
    }
}
