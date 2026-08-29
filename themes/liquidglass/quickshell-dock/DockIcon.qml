// DockIcon.qml — componente reutilizável de ícone do dock (com clipping real)

import Quickshell.Io
import Quickshell.Widgets
import QtQuick

ClippingRectangle {
    id: root
    property string iconPath: ""
    property string bgColor: "#888888"
    property string command: ""

    width: 48
    height: 48
    radius: 14
    color: bgColor
    opacity: mouseArea.containsMouse ? 0.85 : 1.0

    Image {
        anchors.centerIn: parent
        source: root.iconPath
        width: 30
        height: 30
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            launchProc.command = ["sh", "-c", root.command]
            launchProc.running = true
        }
    }

    Process {
        id: launchProc
    }
}
