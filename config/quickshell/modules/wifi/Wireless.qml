import QtQuick
import "../../components"

StatusIcon {
    id: root

    // -1 for netword disconnected, else 0 - 100
    required property int strength

    readonly property list<string> signalPaths: [
        "M9.39883 13.9177C10.3603 13.9177 11.1385 13.1383 11.1385 12.178C11.1385 11.2177 10.3603 10.4383 9.39883 10.4383C8.43851 10.4383 7.65912 11.2177 7.65912 12.178C7.65912 13.1383 8.43851 13.9177 9.39883 13.9177Z",
        "M14.676 8.64056C15.3023 8.01427 15.2443 6.97044 14.4672 6.54131C12.9594 5.70625 11.2313 5.23073 9.39883 5.23073C7.56633 5.23073 5.82662 5.70625 4.33047 6.54131C3.5534 6.97044 3.49541 8.01427 4.12171 8.64056C4.63202 9.15088 5.44389 9.20887 6.09338 8.88412C7.09081 8.397 8.21583 8.11865 9.39883 8.11865C10.5818 8.11865 11.7068 8.397 12.7043 8.88412C13.3538 9.20887 14.1656 9.15088 14.676 8.64056Z",
        "M18.3769 4.94078C18.9684 4.34928 18.9452 3.37504 18.2725 2.88792C15.7789 1.07862 12.717 0 9.4 0C6.08295 0 3.02106 1.06702 0.52747 2.88792C-0.145218 3.37504 -0.168414 4.34928 0.423088 4.94078C0.968197 5.48589 1.83805 5.50909 2.46435 5.06836C4.43602 3.69979 6.82523 2.89952 9.4 2.89952C11.9748 2.89952 14.364 3.69979 16.3356 5.06836C16.9619 5.50909 17.8318 5.48589 18.3769 4.94078Z"
    ]
    readonly property string noInternetPath: "M0.87 0C0.3944 0 0 0.3944 0 0.87V4.35C0 4.8256 0.3944 5.22 0.87 5.22C1.3456 5.22 1.74 4.8256 1.74 4.35V0.87C1.74 0.3944 1.3456 0 0.87 0ZM0.87 8.12C1.3456 8.12 1.74 7.7256 1.74 7.25C1.74 6.7744 1.3456 6.38 0.87 6.38C0.3944 6.38 0 6.7744 0 7.25C0 7.7256 0.3944 8.12 0.87 8.12Z"

    property color fillActive: "white"
    property color fillInactive: Qt.alpha(fillActive, 0.45)
    property bool hasInternetAccess: true

    Item {
        implicitWidth: 18.8
        implicitHeight: 13.92
        anchors.centerIn: parent

        SvgIcon {
            svgPath: root.signalPaths[0]
            sourceWidth: 18.8
            sourceHeight: 13.92
            fillColor: root.strength < 0 ? root.fillInactive : root.fillActive
        }
        SvgIcon {
            svgPath: root.signalPaths[1]
            sourceWidth: 18.8
            sourceHeight: 13.92
            fillColor: root.strength < 33 ? root.fillInactive : root.fillActive
        }
        SvgIcon {
            svgPath: root.signalPaths[2]
            sourceWidth: 18.8
            sourceHeight: 13.92
            fillColor: root.strength < 66 ? root.fillInactive : root.fillActive
        }
        SvgIcon {
            svgPath: root.noInternetPath
            sourceWidth: 1.74
            sourceHeight: 8.12
            fillColor: root.fillActive
            visible: !root.hasInternetAccess
            x: 16.66
            y: 5.8
        }
    }
}
