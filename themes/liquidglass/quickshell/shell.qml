// shell.qml — barra superior liquidglass (Quickshell/QML)

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
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

                // ---- DIREITA: launcher, CPU, RAM, relógio, energia ----
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 14

                    // Launcher de apps (lupa)
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: launcherMouseArea.containsMouse ? "#20000000" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🔍"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: launcherMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.launcherOpen = !bar.launcherOpen
                        }
                    }

                    // Quick toggles (Wi-Fi / Bluetooth)
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: togglesMouseArea.containsMouse ? "#20000000" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰤨"  // ícone wifi (Nerd Font, mesmo set do logo Arch)
                            font.pixelSize: 15
                        }

                        MouseArea {
                            id: togglesMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.togglesOpen = !bar.togglesOpen
                        }
                    }

                    // Notificações (rótulo em texto — evita depender de glifo de ícone)
                    Rectangle {
                        color: notifMouseArea.containsMouse ? "#20000000" : "transparent"
                        radius: 8
                        implicitWidth: notifRow.implicitWidth + 12
                        implicitHeight: 22

                        Row {
                            id: notifRow
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "Avisos"
                                color: "#101012"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Rectangle {
                                visible: notifServer.trackedNotifications.values.length > 0
                                width: 15
                                height: 15
                                radius: 8
                                color: "#c8382e"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: notifServer.trackedNotifications.values.length
                                    color: "#ffffff"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }
                        }

                        MouseArea {
                            id: notifMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.notifHistoryOpen = !bar.notifHistoryOpen
                        }
                    }

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
        // ---- Launcher de apps ----
        property bool launcherOpen: false
        // ---- Quick toggles (Wi-Fi / Bluetooth) ----
        property bool togglesOpen: false
        // ---- Notificações ----
        property bool notifHistoryOpen: false
        // Histórico persistido em memória (snapshot de dados, já que o objeto
        // Notification original é destruído quando expira/é dispensado)
        property var notifHistory: []
        property var nowDate: new Date()
    }

    // ── Servidor de notificações (substitui mako/dunst) ───────
    NotificationServer {
        id: notifServer
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        // false: evita reemitir notificações antigas a cada reload do Quickshell
        keepOnReload: false

        onNotification: (notification) => {
            // precisa marcar tracked=true, senão a notificação é descartada na hora
            notification.tracked = true

            // snapshot pro histórico (o objeto original pode ser destruído depois)
            const entry = {
                appName: notification.appName || "Sistema",
                summary: notification.summary || "",
                body: notification.body || "",
                time: Qt.formatDateTime(new Date(), "hh:mm")
            }
            bar.notifHistory = [entry].concat(bar.notifHistory).slice(0, 50)
        }
    }

    // ── Popups de notificação (toast, canto superior direito) ──
    PanelWindow {
        id: toastWindow
        anchors {
            top: true
            right: true
        }
        margins {
            top: 50
            right: 14
        }
        implicitWidth: 300
        implicitHeight: toastColumn.implicitHeight
        color: "transparent"
        visible: notifServer.trackedNotifications.values.length > 0
        WlrLayershell.namespace: "quickshell-notifications"
        WlrLayershell.layer: WlrLayer.Overlay

        Column {
            id: toastColumn
            width: parent.width
            spacing: 8

            Repeater {
                model: notifServer.trackedNotifications.values
                delegate: Rectangle {
                    id: toastItem
                    required property var modelData
                    width: toastColumn.width
                    height: toastContent.implicitHeight + 20
                    radius: 16
                    color: "#f2ffffff"
                    border.color: "#66ffffff"

                    Column {
                        id: toastContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 2

                        Row {
                            width: parent.width
                            Text {
                                width: parent.width - 20
                                text: (toastItem.modelData.appName || "Sistema") + " — " + (toastItem.modelData.summary || "")
                                font.pixelSize: 13
                                font.bold: true
                                color: "#101012"
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "✕"
                                font.pixelSize: 12
                                color: "#6a6a6e"
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    onClicked: toastItem.modelData.dismiss()
                                }
                            }
                        }

                        Text {
                            visible: (toastItem.modelData.body || "") !== ""
                            width: parent.width
                            text: toastItem.modelData.body || ""
                            font.pixelSize: 11
                            color: "#3a3a3c"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    // auto-dismiss (usa expireTimeout do app se informado, senão 6s)
                    Timer {
                        interval: toastItem.modelData.expireTimeout > 0 ? toastItem.modelData.expireTimeout * 1000 : 6000
                        running: true
                        repeat: false
                        onTriggered: toastItem.modelData.expire()
                    }
                }
            }
        }
    }

    // ── Histórico de notificações ─────────────────────────────
    PopupWindow {
        id: notifHistory
        anchor.window: bar
        // mesma lógica de aproximação do painel de toggles
        anchor.rect.x: bar.width - implicitWidth - 130
        anchor.rect.y: bar.height
        implicitWidth: 300
        implicitHeight: Math.min(400, historyColumn.implicitHeight + 60)
        visible: bar.notifHistoryOpen
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f2ffffff"
            border.color: "#66ffffff"
            radius: 18

            Text {
                visible: bar.notifHistory.length === 0
                anchors.centerIn: parent
                text: "Nenhuma notificação ainda"
                color: "#6a6a6e"
                font.pixelSize: 12
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 14
                anchors.topMargin: 40
                contentHeight: historyColumn.implicitHeight
                clip: true
                visible: bar.notifHistory.length > 0

                Column {
                    id: historyColumn
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: bar.notifHistory
                        delegate: Rectangle {
                            required property var modelData
                            width: historyColumn.width
                            height: entryContent.implicitHeight + 16
                            radius: 10
                            color: "#18000000"

                            Column {
                                id: entryContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 1

                                Row {
                                    width: parent.width
                                    Text {
                                        width: parent.width - 40
                                        text: modelData.appName
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#101012"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: 40
                                        horizontalAlignment: Text.AlignRight
                                        text: modelData.time
                                        font.pixelSize: 10
                                        color: "#6a6a6e"
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.summary
                                    font.pixelSize: 11
                                    color: "#3a3a3c"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }

            // botão limpar histórico
            Text {
                visible: bar.notifHistory.length > 0
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 12
                text: "Limpar"
                font.pixelSize: 11
                color: "#c8382e"
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: bar.notifHistory = []
                }
            }
        }
    }

    PopupWindow {
        id: dashboard
        anchor.window: bar
        anchor.rect.x: (bar.width - implicitWidth) / 2
        anchor.rect.y: bar.height
        implicitWidth: 300
        // altura cresce automaticamente quando o player mpris aparece
        implicitHeight: 440 + (mediaCard.visible ? mediaCard.height + 16 : 0)
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

                Item { width: 1; height: mediaCard.visible ? 10 : 0 }

                // ── Media Player (mpris) ──────────────────────────────
                Rectangle {
                    id: mediaCard
                    visible: Mpris.players.values.length > 0
                    width: 260
                    height: 76
                    radius: 16
                    color: "#22000000"
                    anchors.horizontalCenter: parent.horizontalCenter

                    // pega o primeiro player ativo (geralmente o que está tocando)
                    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // capa (se disponível)
                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            radius: 12
                            color: "#33000000"
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: mediaCard.player ? mediaCard.player.trackArtUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: source !== ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: mediaCard.player ? (mediaCard.player.trackTitle || "Sem título") : ""
                                font.pixelSize: 13
                                font.bold: true
                                color: "#101012"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: mediaCard.player ? (mediaCard.player.trackArtist || "") : ""
                                font.pixelSize: 11
                                color: "#6a6a6e"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 16
                                Layout.topMargin: 4

                                Text {
                                    text: "⏮"
                                    font.pixelSize: 14
                                    color: "#101012"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mediaCard.player && mediaCard.player.previous()
                                    }
                                }
                                Text {
                                    text: mediaCard.player && mediaCard.player.isPlaying ? "⏸" : "▶"
                                    font.pixelSize: 16
                                    color: "#101012"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mediaCard.player && mediaCard.player.togglePlaying()
                                    }
                                }
                                Text {
                                    text: "⏭"
                                    font.pixelSize: 14
                                    color: "#101012"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mediaCard.player && mediaCard.player.next()
                                    }
                                }
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

    // ── Launcher de apps ──────────────────────────────────────
    PopupWindow {
        id: launcher
        anchor.window: bar
        anchor.rect.x: 14
        anchor.rect.y: bar.height
        implicitWidth: 320
        implicitHeight: 400
        visible: bar.launcherOpen
        color: "transparent"

        property var allApps: []
        property string searchText: ""
        property var filteredApps: {
            if (searchText.length === 0) return allApps
            const q = searchText.toLowerCase()
            return allApps.filter(function(a) { return a.name.toLowerCase().indexOf(q) !== -1 })
        }

        function loadApps() {
            listAppsProc.running = true
        }

        function launchApp(execCmd) {
            launchProc.command = ["sh", "-c", "setsid " + execCmd + " >/dev/null 2>&1 &"]
            launchProc.running = true
            bar.launcherOpen = false
        }

        onVisibleChanged: {
            if (visible) {
                searchField.text = ""
                loadApps()
                searchField.forceActiveFocus()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#f2ffffff"
            border.color: "#66ffffff"
            radius: 20

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                TextField {
                    id: searchField
                    width: parent.width
                    height: 36
                    placeholderText: "Buscar aplicativo..."
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 10
                        color: "#20000000"
                    }
                    onTextChanged: launcher.searchText = text
                    Keys.onEscapePressed: bar.launcherOpen = false
                    Keys.onReturnPressed: {
                        if (launcher.filteredApps.length > 0) {
                            launcher.launchApp(launcher.filteredApps[0].exec)
                        }
                    }
                }

                ListView {
                    width: parent.width
                    height: parent.height - searchField.height - 10
                    clip: true
                    model: launcher.filteredApps
                    spacing: 2

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 36
                        radius: 8
                        color: appMouse.containsMouse ? "#20000000" : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            width: parent.width - 20
                            text: modelData.name
                            font.pixelSize: 13
                            color: "#101012"
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: launcher.launchApp(modelData.exec)
                        }
                    }
                }
            }
        }

        // Lista .desktop files do sistema e extrai Name= / Exec=
        Process {
            id: listAppsProc
            command: ["sh", "-c", "for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do [ -f \"$f\" ] || continue; name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); execline=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed 's/%[a-zA-Z]//g'); nodisplay=$(grep -m1 '^NoDisplay=true' \"$f\"); if [ -n \"$name\" ] && [ -n \"$execline\" ] && [ -z \"$nodisplay\" ]; then echo \"$name|||$execline\"; fi; done | sort -u"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const lines = text.trim().split("\n").filter(function(l) { return l.length > 0 })
                    const apps = []
                    const seen = {}
                    for (const line of lines) {
                        const parts = line.split("|||")
                        if (parts.length < 2) continue
                        const name = parts[0].trim()
                        const execCmd = parts[1].trim()
                        if (!name || !execCmd || seen[name]) continue
                        seen[name] = true
                        apps.push({ name: name, exec: execCmd })
                    }
                    launcher.allApps = apps
                }
            }
        }

        Process {
            id: launchProc
        }
    }

    // ── Quick toggles (Wi-Fi / Bluetooth) ─────────────────────
    PopupWindow {
        id: toggles
        anchor.window: bar
        // Aproximação: o botão 📶 fica à esquerda do grupo CPU/RAM/relógio/energia,
        // então ancoramos a partir da borda direita da barra, com uma folga que
        // "pula" esse grupo. Se ainda ficar deslocado do ícone, ajuste esse -230.
        anchor.rect.x: bar.width - implicitWidth - 230
        anchor.rect.y: bar.height
        implicitWidth: 240
        implicitHeight: togglesColumn.implicitHeight + 28
        visible: bar.togglesOpen
        color: "transparent"

        property bool wifiEnabled: false
        property bool btEnabled: false

        function refresh() {
            wifiCheckProc.running = true
            btCheckProc.running = true
        }

        onVisibleChanged: {
            if (visible) refresh()
        }

        Rectangle {
            anchors.fill: parent
            color: "#f2ffffff"
            border.color: "#66ffffff"
            radius: 18

            Column {
                id: togglesColumn
                anchors.centerIn: parent
                width: parent.width - 28
                spacing: 14

                // ---- Linha Wi-Fi ----
                RowLayout {
                    width: parent.width
                    spacing: 10

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true
                        Text { text: "Wi-Fi"; color: "#101012"; font.pixelSize: 14; font.bold: true }
                        Text {
                            text: toggles.wifiEnabled ? "Ativado" : "Desativado"
                            color: "#6a6a6e"
                            font.pixelSize: 11
                        }
                    }

                    // switch
                    Rectangle {
                        id: wifiSwitch
                        width: 44
                        height: 24
                        radius: 12
                        color: toggles.wifiEnabled ? "#0a0a0c" : "#30000000"

                        Rectangle {
                            id: wifiKnob
                            width: 18
                            height: 18
                            radius: 9
                            color: "#ffffff"
                            y: 3
                            x: toggles.wifiEnabled ? (parent.width - width - 3) : 3
                            Behavior on x { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                wifiToggleProc.command = ["sh", "-c", "nmcli radio wifi " + (toggles.wifiEnabled ? "off" : "on")]
                                wifiToggleProc.running = true
                            }
                        }
                    }
                }

                // ---- Linha Bluetooth ----
                RowLayout {
                    width: parent.width
                    spacing: 10

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true
                        Text { text: "Bluetooth"; color: "#101012"; font.pixelSize: 14; font.bold: true }
                        Text {
                            text: toggles.btEnabled ? "Ativado" : "Desativado"
                            color: "#6a6a6e"
                            font.pixelSize: 11
                        }
                    }

                    // switch
                    Rectangle {
                        id: btSwitch
                        width: 44
                        height: 24
                        radius: 12
                        color: toggles.btEnabled ? "#0a0a0c" : "#30000000"

                        Rectangle {
                            id: btKnob
                            width: 18
                            height: 18
                            radius: 9
                            color: "#ffffff"
                            y: 3
                            x: toggles.btEnabled ? (parent.width - width - 3) : 3
                            Behavior on x { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                btToggleProc.command = ["sh", "-c", "bluetoothctl power " + (toggles.btEnabled ? "off" : "on")]
                                btToggleProc.running = true
                            }
                        }
                    }
                }
            }
        }

        // ---- Checagem de status ----
        Process {
            id: wifiCheckProc
            command: ["sh", "-c", "nmcli radio wifi"]
            stdout: StdioCollector {
                onStreamFinished: {
                    toggles.wifiEnabled = text.trim() === "enabled"
                }
            }
        }

        Process {
            id: btCheckProc
            command: ["sh", "-c", "bluetoothctl show | grep -i Powered"]
            stdout: StdioCollector {
                onStreamFinished: {
                    toggles.btEnabled = text.toLowerCase().indexOf("yes") !== -1
                }
            }
        }

        // ---- Ações de toggle (reconsulta status logo em seguida) ----
        Process {
            id: wifiToggleProc
            stdout: StdioCollector {
                onStreamFinished: wifiRecheckTimer.start()
            }
        }

        Process {
            id: btToggleProc
            stdout: StdioCollector {
                onStreamFinished: btRecheckTimer.start()
            }
        }

        Timer {
            id: wifiRecheckTimer
            interval: 600
            repeat: false
            onTriggered: wifiCheckProc.running = true
        }

        Timer {
            id: btRecheckTimer
            interval: 600
            repeat: false
            onTriggered: btCheckProc.running = true
        }
    }
}
