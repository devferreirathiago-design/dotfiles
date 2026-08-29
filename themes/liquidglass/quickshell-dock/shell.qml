// dock.qml — dock inferior liquidglass (Quickshell/QML)

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: dock
        anchors {
            bottom: true
        }
        margins {
            bottom: 12
        }

        WlrLayershell.namespace: "quickshell-dock"
        WlrLayershell.layer: WlrLayer.Top

        implicitWidth: dockRow.implicitWidth + 28
        implicitHeight: 64
        color: "transparent"

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 12

            DockIcon {
                iconPath: "/usr/share/icons/hicolor/scalable/apps/kitty.svg"
                bgColor: "#141416"
                command: "kitty"
            }
            DockIcon {
                iconPath: "/opt/floorp/browser/chrome/icons/default/default128.png"
                bgColor: "#ff8a3d"
                command: "floorp"
            }
            DockIcon {
                iconPath: "/usr/share/icons/hicolor/scalable/apps/org.xfce.thunar.svg"
                bgColor: "#3a94d8"
                command: "thunar"
            }
            DockIcon {
                iconPath: "/home/ferreira/.local/share/icons/kora/apps/scalable/vscode.svg"
                bgColor: "#2c6cc4"
                command: "code"
            }
            Rectangle {
                width: 1
                height: 36
                color: "#20000000"
                anchors.verticalCenter: parent.verticalCenter
            }
            DockIcon {
                iconPath: "/usr/share/icons/breeze/apps/48/preferences-system.svg"
                bgColor: "#88888e"
                command: "xfce4-settings-manager"
            }
        }
    }
}
