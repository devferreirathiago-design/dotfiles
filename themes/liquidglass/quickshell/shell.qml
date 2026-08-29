// shell.qml — barra superior liquidglass (Quickshell/QML)

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 40
        color: "transparent"

        // Namespace pra aplicar blur do Hyprland via layer_rule
        WlrLayershell.namespace: "quickshell-bar"
        WlrLayershell.layer: WlrLayer.Top

        // ---- Fundo de vidro ----
        Rectangle {
            anchors.fill: parent
            color: "#40ffffff"
            border.color: "#66ffffff"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 0

                // ---- ESQUERDA: logo Arch + nome da janela ----
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Text {
                        text: "󰣇"  // glifo Arch (Nerd Font)
                        color: "#1793d1"
                        font.pixelSize: 16
                    }

                    Text {
                        text: {
                            if (!Hyprland.activeToplevel || !Hyprland.focusedWorkspace) return ""
                            if (!Hyprland.activeToplevel.workspace) return ""
                            if (Hyprland.activeToplevel.workspace.id !== Hyprland.focusedWorkspace.id) return ""
                            return Hyprland.activeToplevel.title
                        }
                        color: "#101012"
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.maximumWidth: 260
                    }
                }

                Item { Layout.fillWidth: true }

                // ---- CENTRO: workspaces ----
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    color: "#4dffffff"
                    radius: height / 2
                    implicitHeight: 28
                    implicitWidth: wsRow.implicitWidth + 8

                    Row {
                        id: wsRow
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                required property var modelData
                                property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

                                width: 24
                                height: 24
                                radius: 12
                                color: active ? "#0a0a0c" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.id
                                    color: active ? "#ffffff" : "#161618"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        wsProc.command = ["hyprctl", "dispatch", "hl.dsp.focus({workspace=" + modelData.id + "})"]
                                        wsProc.running = true
                                    }
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // ---- DIREITA: CPU, RAM, relógio, energia ----
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 14

                    // CPU com rótulo claro
                    RowLayout {
                        spacing: 4
                        Text { text: "CPU"; color: "#6a6a6e"; font.pixelSize: 10 }
                        Text { text: cpuMonitor.usage + "%"; color: "#101012"; font.pixelSize: 12; font.bold: true }
                    }

                    // RAM com rótulo claro
                    RowLayout {
                        spacing: 4
                        Text { text: "RAM"; color: "#6a6a6e"; font.pixelSize: 10 }
                        Text { text: ramMonitor.usage + "%"; color: "#101012"; font.pixelSize: 12; font.bold: true }
                    }

                    // Relógio
                    Text {
                        id: clockText
                        color: "#101012"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    // Botão de energia com menu dropdown de verdade
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: powerMouseArea.containsMouse ? "#c8382e" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: powerMouseArea.containsMouse ? "#ffffff" : "#c8382e"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: powerMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.powerMenuOpen = !bar.powerMenuOpen
                        }
                    }
                }
            }
        }

        // ---- Menu de energia (PopupWindow real, não fica preso à altura da barra) ----
        property bool powerMenuOpen: false
    }

    PopupWindow {
        id: powerMenu
        anchor.window: bar
        anchor.rect.x: bar.width - implicitWidth - 14
        anchor.rect.y: bar.height
        implicitWidth: 160
        implicitHeight: powerMenuColumn.implicitHeight + 12
        visible: bar.powerMenuOpen
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f2ffffff"
            border.color: "#66ffffff"
            radius: 14

            Column {
                id: powerMenuColumn
                anchors.centerIn: parent
                width: parent.width - 12
                spacing: 2

                Repeater {
                    model: [
                        { label: "Desligar", action: "poweroff" },
                        { label: "Reiniciar", action: "reboot" },
                        { label: "Logout", action: "logout" }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 34
                        radius: 8
                        color: itemMouse.containsMouse ? "#20000000" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: modelData.action === "poweroff" || modelData.action === "reboot" ? "#c8382e" : "#101012"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                bar.powerMenuOpen = false
                                if (modelData.action === "poweroff") {
                                    powerProc.command = ["systemctl", "poweroff"]
                                    powerProc.running = true
                                } else if (modelData.action === "reboot") {
                                    powerProc.command = ["systemctl", "reboot"]
                                    powerProc.running = true
                                } else if (modelData.action === "logout") {
                                    powerProc.command = ["hyprctl", "dispatch", "hl.dsp.exit()"]
                                    powerProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }

        // Força atualização do toplevel ativo quando a janela em foco muda
        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.name === "activewindow" || event.name === "activewindowv2" || event.name === "workspace") {
                    Hyprland.refreshToplevels()
                    Hyprland.refreshWorkspaces()
                }
            }
        }

        Process {
            id: wsProc
        }

        Process {
            id: powerProc
            stdout: StdioCollector {
                onStreamFinished: console.log("POWERPROC STDOUT:", text)
            }
            stderr: StdioCollector {
                onStreamFinished: console.log("POWERPROC STDERR:", text)
            }
        }

        // ---- Relógio: atualiza a cada segundo ----
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                const d = new Date()
                clockText.text = d.getHours().toString().padStart(2, "0") + ":" + d.getMinutes().toString().padStart(2, "0")
            }
        }

        // ---- CPU: lê /proc/stat a cada 3s ----
        QtObject {
            id: cpuMonitor
            property int usage: 0
            property var lastIdle: 0
            property var lastTotal: 0
        }

        Process {
            id: cpuProc
            command: ["sh", "-c", "grep 'cpu ' /proc/stat"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts = text.trim().split(/\s+/).slice(1).map(Number)
                    const idle = parts[3]
                    const total = parts.reduce((a, b) => a + b, 0)
                    const diffIdle = idle - cpuMonitor.lastIdle
                    const diffTotal = total - cpuMonitor.lastTotal
                    if (cpuMonitor.lastTotal > 0 && diffTotal > 0) {
                        cpuMonitor.usage = Math.round(100 * (1 - diffIdle / diffTotal))
                    }
                    cpuMonitor.lastIdle = idle
                    cpuMonitor.lastTotal = total
                }
            }
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: cpuProc.running = true
        }

        // ---- RAM: lê /proc/meminfo a cada 3s ----
        QtObject {
            id: ramMonitor
            property int usage: 0
        }

        Process {
            id: ramProc
            command: ["sh", "-c", "grep -E 'MemTotal|MemAvailable' /proc/meminfo"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const lines = text.trim().split("\n")
                    const total = parseInt(lines[0].match(/\d+/)[0])
                    const avail = parseInt(lines[1].match(/\d+/)[0])
                    ramMonitor.usage = Math.round(100 * (1 - avail / total))
                }
            }
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: ramProc.running = true
        }
    }
}
