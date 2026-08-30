# STATUS DO PROJETO — Tema liquidglass (Hyprland + Quickshell/QML)

Última atualização: sessão de 29/08/2026

## Contexto geral
Usuário: xampoo (Thiago), Arch Linux + Hyprland, GPU AMD RX 7600.
Migrou de waybar+eww (GTK/CSS) pra Quickshell/QML por causa de limitações
de fluidez visual do GTK (sem backdrop-filter real, bugs de box-shadow
cortado, etc). Waybar e eww estão DESATIVADOS (comentados no autostart).

## Estrutura de arquivos (tudo dentro de ~/dotfiles, com symlinks pro real path)
- `themes/liquidglass/hypr/hyprland.lua` → symlink em `~/.config/hypr/hyprland.lua`
- `themes/liquidglass/quickshell/shell.qml` → symlink em `~/.config/quickshell/liquidglass/shell.qml`
  (essa é a BARRA superior)
- `themes/liquidglass/quickshell-dock/shell.qml` e `DockIcon.qml`
  → copiados (NÃO symlink ainda) em `~/.config/quickshell/dock/`
  (esse é o DOCK inferior — considerar transformar em symlink também)
- `themes/liquidglass/quickshell-dashboard/ROADMAP.md` e `referencia.png`
  (plano do dashboard, ver abaixo)

## ⚠️ ARMADILHA RECORRENTE — symlinks quebrados
Toda vez que se faz `mv ~/Downloads/arquivo.lua ~/.config/hypr/hyprland.lua`,
isso DESTRÓI o symlink e cria um arquivo solto (quebra a ligação com o git).
**Sempre salvar direto no destino real dentro de `~/dotfiles/themes/liquidglass/...`**,
nunca direto em `~/.config/...`.

## ⚠️ ARMADILHA — pkill quickshell mata os dois processos
`pkill quickshell` mata TANTO a barra quanto o dock (mesmo nome de processo).
Usar sempre `pkill -f "quickshell -c liquidglass"` ou `pkill -f "quickshell -c dock"`
pra matar só um. Subir com `& disown` pra sobreviver ao fechamento do terminal.

## ⚠️ Peculiaridade do Hyprland desse sistema — modo Lua customizado
O `hyprland.lua` usa uma API própria (`hl.bind`, `hl.dsp.*`, `hl.config`,
`hl.window_rule`, `hl.layer_rule`, `hl.monitor`, `hl.on`). Doc real existe em
https://alejandrominaya.github.io/hyprland-lua-docs/ (verificar sempre antes
de supor nome de campo/função — já erramos várias vezes).

Dispatches via `hyprctl dispatch` OU `Hyprland.dispatch()` do Quickshell
**não aceitam sintaxe padrão** (tipo `"exit"` ou `"workspace 1"`). O sistema
espera uma chamada Lua tipo `hl.dsp.exit()` ou `hl.dsp.focus({workspace=N})`.
Erro típico se errar: "expected a dispatcher (e.g. hl.dsp.window.close())".

Isso já foi resolvido em dois lugares no shell.qml:
- Logout: `powerProc.command = ["hyprctl", "dispatch", "hl.dsp.exit()"]`
- Troca de workspace: `wsProc.command = ["hyprctl", "dispatch", "hl.dsp.focus({workspace=" + id + "})"]`

Se aparecer mais algum dispatch quebrado no futuro, aplicar o mesmo padrão
(`hl.dsp.<algo>(...)`) e testar.

## Lições de API do Quickshell (confirmadas via doc oficial, quickshell.org/docs)
- `Process`: usar padrão `proc.command = [...]; proc.running = true`
  (NÃO existe método `.exec()`)
- Captura de erro: `stdout: StdioCollector { onStreamFinished: ... }` e
  mesma coisa pra `stderr` — sem isso, erros do processo são engolidos
  silenciosamente (isso nos custou várias rodadas de debug)
- `Popup` do QtQuick.Controls NÃO funciona bem dentro de `PanelWindow`
  (falta a camada "Overlay" que só existe em ApplicationWindow) — usar
  `PopupWindow` do próprio Quickshell no lugar, com `anchor.window` e
  `anchor.rect.x/y`
- `ClippingRectangle` (de `Quickshell.Widgets`) resolve o problema de
  ícones com fundo quadrado vazando pra fora de cantos arredondados —
  bem melhor que a gambiarra que fizemos no eww (trocar por symbolic)
- `WlrLayershell.namespace` define o nome que o `hl.layer_rule` do
  Hyprland usa pra aplicar blur — cada PanelWindow precisa de um
  namespace único, e uma regra correspondente em hyprland.lua
- Hyprland.workspaces inclui workspaces ESPECIAIS (scratchpad, tipo o
  "steam") com ID NEGATIVO — filtrar com `visible: modelData.id > 0`
  no delegate do Repeater, senão aparece um "-98" estranho na lista
- CSS: `filter:` não é suportado, `!important` quebra o parser scss
  do eww/grass — evitar essas duas coisas (isso era mais relevante pra
  fase eww/GTK, mas vale lembrar caso volte a mexer em CSS)

## O que já está 100% funcional (barra — shell.qml)
- Vidro translúcido com blur real (via hl.layer_rule, namespace "quickshell-bar")
- Logo do Arch + nome da janela ativa (correto mesmo trocando de workspace,
  usando Connections com Hyprland.onRawEvent pra refreshToplevels/refreshWorkspaces)
- Workspaces dinâmicos clicáveis, centralizados, especiais filtrados
- CPU e RAM com rótulos claros (lendo /proc/stat e /proc/meminfo a cada 3s)
- Relógio clicável que abre o painel do dashboard (ver abaixo)
- Menu de energia (ícone ⏻ vermelho): Desligar / Reiniciar / Logout,
  todos funcionando com um clique (via PopupWindow)

## O que já está 100% funcional (dock — quickshell/dock/shell.qml + DockIcon.qml)
- 5 ícones reais e clicáveis: kitty (terminal), Floorp (ícone real dele,
  em /opt/floorp/browser/chrome/icons/default/default128.png — NÃO tem
  ícone no sistema, foi copiado do próprio diretório de instalação),
  Thunar (arquivos), VSCode, xfce4-settings-manager (configurações)
- `ClippingRectangle` garante que os ícones ficam bem cortados no
  cantinho arredondado, sem vazamento de fundo quadrado
- Ancorado só com `bottom: true` (centraliza sozinho no eixo horizontal,
  comportamento padrão do wlr-layer-shell quando não se ancora os lados)

## Autostart (hyprland.lua, dentro de hl.on("hyprland.start", ...))
```lua
hl.exec_cmd("kitty")
-- hl.exec_cmd("waybar")  -- DESATIVADO
hl.exec_cmd("quickshell -c liquidglass")
hl.exec_cmd("quickshell -c dock")
hl.exec_cmd("setsid awww-daemon --format xrgb")
-- hl.exec_cmd("eww daemon")       -- DESATIVADO
-- hl.exec_cmd("eww open dock")    -- DESATIVADO
```
Confirmado funcionando via reboot real (barra + dock sobem sozinhos).

## Dashboard (painel que abre ao clicar no relógio) — progresso do roadmap
Roadmap completo em `themes/liquidglass/quickshell-dashboard/ROADMAP.md`
(mockup de referência: Caelestia Shell, visto no Reddit r/hyprland)

- [x] **Etapa 1** — Painel de vidro com relógio grande + data por extenso
  em português (arrays manuais de dias/meses, já que Qt não localiza pt-BR
  por padrão nesse contexto)
- [x] **Etapa 2** — Calendário interativo: navegação de mês (‹ ›), grid
  7 colunas, dia atual destacado, dias de mês anterior/seguinte em cinza
- [x] **Etapa 3** — Clima via Open-Meteo (API gratuita, sem chave):
  coordenadas fixas de Guaratiba/RJ (lat -22.9977, lon -43.6247, usuário
  pode ter mudado de local — perguntar se ainda é válido), busca a cada
  15 min via `curl` num `Process`, ícones emoji simples (☀ 🌤 ☁ 🌧 etc),
  mapeamento de weathercode (padrão WMO) pra português
- [ ] **Etapa 4** — Player de mídia via `Quickshell.Services.Mpris`
      (módulo pronto do Quickshell, pega Spotify/YouTube automaticamente)
- [ ] **Etapa 5** — Launcher de apps com busca via `Quickshell.DesktopEntries`
- [ ] **Etapa 6** — Quick Toggles (Wi-Fi via `Quickshell.Networking`,
      Bluetooth via `Quickshell.Bluetooth`)
- [ ] **Etapa 7** — Notificações via `Quickshell.Services.Notifications`
      (poderia substituir o daemon de notificação atual, se houver um)

## Pendências gerais (fora do dashboard, mencionadas em sessões anteriores)
- Testar comportamento de jogos em fullscreen mais a fundo (stutter na
  transição de fullscreen foi parcialmente mitigado com
  `WLR_DRM_NO_ATOMIC=1`, mas não 100% resolvido — pode ser característica
  do Hyprland/AMD, aceito como está por ora)
- `userChrome.css` do Floorp pra estilizar a interface interna do navegador
  (só a transparência da janela em si foi feita via window_rule de opacity)
- Considerar transformar o dock em symlink também (hoje é cópia solta)

## Como retomar numa conversa nova
Colar o conteúdo deste arquivo no início da conversa (ou pedir pro Claude
rodar `cat ~/dotfiles/PROGRESS.md` se tiver acesso ao terminal do usuário
via prints). Isso deve ser suficiente pra continuar exatamente de onde
paramos, sem precisar re-explicar a arquitetura nem redescobrir os
mesmos bugs de API.
