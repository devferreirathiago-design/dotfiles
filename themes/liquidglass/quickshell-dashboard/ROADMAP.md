# Roadmap — Dashboard estilo Caelestia em Quickshell/QML

## Referência visual
Imagem salva em: `themes/liquidglass/quickshell-dashboard/referencia.png`
(print de um dashboard estilo Caelestia Shell, visto no Reddit)

## O que já temos prontos (base sólida)
- Barra Quickshell/QML funcionando: vidro com blur real, workspaces,
  CPU/RAM, relógio, título de janela, menu de energia (Desligar/Reiniciar/Logout)
- Dock Quickshell/QML: 5 ícones reais e clicáveis (kitty, Floorp, Thunar,
  VSCode, configurações), com clipping correto via `ClippingRectangle`
- Ambos sobem sozinhos no boot (autostart confirmado via reboot real)
- Aprendemos na prática: bindings reativos, `id`, `PopupWindow`,
  `ClippingRectangle`, padrão `command`+`running` do `Process`,
  e a peculiaridade do `hl.dsp.*` (Hyprland em modo Lua) pra dispatch

## O que o dashboard de referência tem (dividir em etapas)

### Etapa 1 — Painel base + relógio/data grandes
- Um painel de vidro que abre/fecha (parecido com o menu de energia que já
  construímos, só que maior)
- Relógio grande + data por extenso

### Etapa 2 — Calendário interativo
- Grade de dias do mês, navegação mês anterior/próximo
- Pode usar JS puro dentro do QML pra calcular os dias (sem lib externa)

### Etapa 3 — Clima
- Precisa de uma API externa (ex: Open-Meteo, que é gratuita e sem
  necessidade de chave) via `Quickshell.Io.Process` rodando `curl`,
  ou XMLHttpRequest direto em QML

### Etapa 4 — Player de mídia (mpris)
- Quickshell já tem um módulo pronto pra isso: `Quickshell.Services.Mpris`
- Pega automaticamente o que está tocando (Spotify, YouTube, etc)
  sem precisar de script externo

### Etapa 5 — Launcher de apps com busca
- Lista de apps instalados via `Quickshell.DesktopEntries`
  (outro módulo pronto do Quickshell)
- Campo de busca filtrando em tempo real

### Etapa 6 — Quick Toggles (Wi-Fi, Bluetooth, etc)
- Wi-Fi: módulo `Quickshell.Networking`
- Bluetooth: módulo `Quickshell.Bluetooth`
- Ambos nativos do Quickshell, não precisam de script externo

### Etapa 7 — Notificações
- Módulo `Quickshell.Services.Notifications`
- Substitui o `mako`/daemon de notificação atual, se quiser

## Ordem sugerida
Começar pela Etapa 1 (painel + relógio) por ser mais simples e já
reaproveitar o que aprendemos com o menu de energia. Depois seguir na
ordem que fizer mais sentido — cada etapa é independente das outras.

## Observação importante
Cada um desses módulos "prontos" do Quickshell precisa ter a API
confirmada via documentação oficial (quickshell.org/docs) antes de
implementar — já apanhamos bastante ontem/hoje chutando nomes de
propriedade errados. Vale sempre `web_fetch` na doc antes de escrever
código novo.
