import QtQuick
import QtQuick.Shapes

Item {
    required property int batteryState
    required property int level

    readonly property list<string> framePaths: [
        // bolt
        "M20 0C22.183 0 23.9564 1.7488 23.998 3.92188L21.8057 6.46289L21.8018 6.4668C21.1652 7.21295 21.5939 8.52523 22.7314 8.52539H24V9C24 11.2091 22.2091 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // defend
        "M20 0C21.6595 0 23.0819 1.01094 23.6875 2.4502C23.4731 2.54806 23.269 2.63585 23.082 2.71094L22.4805 2.9375C21.8586 3.15306 21.5 3.74339 21.5 4.33691V4.35449L21.501 4.37109C21.607 7.15754 22.638 9.0252 23.7217 10.2002C23.7445 10.2249 23.7682 10.2484 23.791 10.2725C23.2592 11.8574 21.764 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // plus
        "M20 0C22.2091 0 24 1.79086 24 4V4.7002H23.2002C22.2062 4.70029 21.3994 5.506 21.3994 6.5C21.3994 7.4953 22.2075 8.29873 23.2002 8.29883H24V9C24 11.2091 22.2091 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // question
        "M20 0C21.2227 0 22.3161 0.549588 23.0498 1.41406C22.9688 1.47396 22.8901 1.53686 22.8145 1.60352C22.4921 1.88625 22.2067 2.21541 22.042 2.59863L22.0391 2.60547L22.0361 2.61133C21.8622 3.03432 21.8545 3.48365 22.0117 3.91211L22.0156 3.92188C22.1766 4.34455 22.4743 4.68228 22.8896 4.88379L22.9004 4.88867C23.2252 5.04077 23.6016 5.12244 24 5.0498V5.9707C23.8462 6.31171 23.7793 6.68032 23.7793 7.05664V7.08789C23.7793 7.39339 23.8598 7.67133 24 7.91504V8.97656C23.6815 9.34878 23.5157 9.80407 23.5156 10.3037C23.5156 10.4736 23.5364 10.6382 23.5732 10.7969C22.915 12.1033 21.5627 13 20 13H4C1.79086 13 0 11.2091 0 9V4C0 1.79086 1.79086 0 4 0H20Z",
        // default
        "M4,0L20,0A4,4 0 0 1 24,4L24,9A4,4 0 0 1 20,13L4,13A4,4 0 0 1 0,9L0,4A4,4 0 0 1 4,0Z"
    ]
    readonly property string activeFrame: framePaths[batteryState]

    property color backgroundColor: "gray"
    property color fillColor: "black"

    id: root
    width: 24
    height: 13

    // background shell
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.backgroundColor
            strokeWidth: 0
            PathSvg { path: root.activeFrame }
        }
    }

    Item {
        visible: root.level > 0
        width: Math.ceil((root.level / 100) * 24)
        height: parent.height
        clip: true

        Shape {
            width: 24
            height: 13
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: root.fillColor
                strokeWidth: 0
                PathSvg { path: root.activeFrame }
            }
        }
    }
}
