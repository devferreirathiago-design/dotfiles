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

                                visible: modelData.id > 0
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

                    // Relógio (clicável, abre o painel do dashboard)
                    Rectangle {
                        color: clockMouse.containsMouse ? "#20000000" : "transparent"
                        radius: 8
                        implicitWidth: clockText.implicitWidth + 12
                        implicitHeight: 22

                        Text {
                            id: clockText
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(bar.nowDate, "hh:mm")
                            color: "#101012"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: clockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.dashboardOpen = !bar.dashboardOpen
                        }
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
        // ---- Dashboard (painel grande de relógio/data, próximas etapas do roadmap) ----
        property bool dashboardOpen: false
        property var nowDate: new Date()
    }

    PopupWindow {
        id: dashboard
        anchor.window: bar
        anchor.rect.x: (bar.width - implicitWidth) / 2
        anchor.rect.y: bar.height
        implicitWidth: 300
        implicitHeight: 440
        visible: bar.dashboardOpen
        color: "transparent"

        // Nomes em português — QML/Qt.formatDateTime não localiza pt-BR por padrão
        property var diasSemana: ["Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"]
        property var diasSemanaAbrev: ["D", "S", "T", "Q", "Q", "S", "S"]
        property var meses: ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"]

        // ---- Calendário ----
        property int viewMonth: bar.nowDate.getMonth()
        property int viewYear: bar.nowDate.getFullYear()
        property var calendarDays: []

        function buildCalendar() {
            const firstDay = new Date(viewYear, viewMonth, 1)
            const startWeekday = firstDay.getDay()
            const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
            const daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate()
            let cells = []

            for (let i = startWeekday - 1; i >= 0; i--) {
                cells.push({ day: daysInPrevMonth - i, current: false })
            }
            for (let d = 1; d <= daysInMonth; d++) {
                cells.push({ day: d, current: true })
            }
            let nextDay = 1
            while (cells.length < 42) {
                cells.push({ day: nextDay, current: false })
                nextDay++
            }
            calendarDays = cells
        }

        function prevMonth() {
            if (viewMonth === 0) { viewMonth = 11; viewYear-- } else { viewMonth-- }
            buildCalendar()
        }

        function nextMonth() {
            if (viewMonth === 11) { viewMonth = 0; viewYear++ } else { viewMonth++ }
            buildCalendar()
        }

        Component.onCompleted: buildCalendar()

        // ---- Clima (Open-Meteo, sem necessidade de chave de API) ----
        function weatherInfo(code) {
            if (code === 0) return { icon: "☀", label: "Céu limpo" }
            if (code <= 2) return { icon: "🌤", label: "Poucas nuvens" }
            if (code === 3) return { icon: "☁", label: "Nublado" }
            if (code === 45 || code === 48) return { icon: "🌫", label: "Neblina" }
            if (code >= 51 && code <= 57) return { icon: "🌦", label: "Garoa" }
            if (code >= 61 && code <= 67) return { icon: "🌧", label: "Chuva" }
            if (code >= 71 && code <= 77) return { icon: "❄", label: "Neve" }
            if (code >= 80 && code <= 82) return { icon: "🌧", label: "Pancadas de chuva" }
            if (code >= 95) return { icon: "⛈", label: "Tempestade" }
            return { icon: "🌡", label: "—" }
        }

        Rectangle {
            anchors.fill: parent
            color: "#f2ffffff"
            border.color: "#66ffffff"
            radius: 20

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(bar.nowDate, "hh:mm")
                    color: "#101012"
                    font.pixelSize: 56
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dashboard.diasSemana[bar.nowDate.getDay()]
                    color: "#3a3a3c"
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: bar.nowDate.getDate() + " de " + dashboard.meses[bar.nowDate.getMonth()] + " de " + bar.nowDate.getFullYear()
                    color: "#6a6a6e"
                    font.pixelSize: 13
                }

                // ---- Clima ----
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: weatherMonitor.loaded
                    text: weatherMonitor.icon + "  " + weatherMonitor.temp + "°C — " + weatherMonitor.label
                    color: "#3a3a3c"
                    font.pixelSize: 13
                    font.bold: true
                }

                Item { width: 1; height: 10 }

                // ---- Navegação do mês ----
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16

                    Text {
                        text: "‹"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#101012"
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: dashboard.prevMonth()
                        }
                    }

                    Text {
                        text: dashboard.meses[dashboard.viewMonth] + " " + dashboard.viewYear
                        font.pixelSize: 13
                        font.bold: true
                        color: "#101012"
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#101012"
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: dashboard.nextMonth()
                        }
                    }
                }

                // ---- Cabeçalho dos dias da semana ----
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 7
                    columnSpacing: 4

                    Repeater {
                        model: dashboard.diasSemanaAbrev
                        delegate: Text {
                            required property string modelData
                            width: 30
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.pixelSize: 11
                            color: "#6a6a6e"
                        }
                    }
                }

                // ---- Grid de dias do mês ----
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 7
                    columnSpacing: 4
                    rowSpacing: 4

                    Repeater {
                        model: dashboard.calendarDays
                        delegate: Rectangle {
                            required property var modelData
                            property bool isToday: modelData.current
                                && modelData.day === bar.nowDate.getDate()
                                && dashboard.viewMonth === bar.nowDate.getMonth()
                                && dashboard.viewYear === bar.nowDate.getFullYear()

                            width: 30
                            height: 26
                            radius: 8
                            color: isToday ? "#0a0a0c" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                font.pixelSize: 12
                                color: isToday ? "#ffffff" : (modelData.current ? "#101012" : "#c0c0c0")
                            }
                        }
                    }
                }
            }
        }
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
            onTriggered: bar.nowDate = new Date()
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

        // ---- Clima: busca a cada 15 minutos via Open-Meteo ----
        QtObject {
            id: weatherMonitor
            property real temp: 0
            property string icon: ""
            property string label: ""
            property bool loaded: false
        }

        Process {
            id: weatherProc
            command: ["sh", "-c", "curl -s 'https://api.open-meteo.com/v1/forecast?latitude=-22.9977&longitude=-43.6247&current_weather=true&timezone=America/Sao_Paulo'"]
            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        const data = JSON.parse(text)
                        const info = dashboard.weatherInfo(data.current_weather.weathercode)
                        weatherMonitor.temp = Math.round(data.current_weather.temperature)
                        weatherMonitor.icon = info.icon
                        weatherMonitor.label = info.label
                        weatherMonitor.loaded = true
                    } catch (e) {
                        console.log("Erro ao processar clima:", e)
                    }
                }
            }
        }

        Timer {
            interval: 900000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: weatherProc.running = true
        }
    }
}
