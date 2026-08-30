# STATUS DO PROJETO — Tema "liquidglass" (Arch Linux + Hyprland + Quickshell/QML)

Última atualização: 30/08/2026

## Contexto geral
Usuário: xampoo (Thiago), Arch Linux + Hyprland, GPU AMD RX 7600.
Desktop customizado do zero com estética "Liquid Glass" (vidro translúcido +
blur, inspirado no macOS). Migrado de waybar+eww (GTK/CSS) pra Quickshell/QML
por limitação de fluidez visual do GTK. Waybar e eww estão desativados.

## Estrutura de arquivos (tudo em ~/dotfiles, com symlinks pro path real)
- `themes/liquidglass/hypr/hyprland.lua` → symlink em `~/.config/hypr/hyprland.lua`
- `themes/liquidglass/quickshell/shell.qml` → symlink em `~/.config/quickshell/liquidglass/shell.qml`
  (barra superior + dashboard + todos os popups)
- `themes/liquidglass/quickshell-dock/shell.qml` + `DockIcon.qml`
  → symlink em `~/.config/quickshell/dock/` (dock inferior)
- `themes/liquidglass/floorp/userChrome.css` → symlink no perfil do Floorp

## ⚠️ Armadilhas conhecidas (não repetir)
- **Symlinks quebram com `mv` pra `~/.config`**: sempre salvar/mover pro
  destino real dentro de `~/dotfiles/themes/liquidglass/...`, nunca direto em
  `~/.config/...`.
- **`pkill quickshell` mata os dois processos** (barra e dock têm o mesmo
  nome). Usar `pkill -f "quickshell -c liquidglass"` ou `pkill -f "quickshell -c dock"`.
- **Hyprland em modo Lua customizado**: API própria (`hl.bind`, `hl.dsp.*`,
  `hl.config`, `hl.window_rule`, `hl.layer_rule`, `hl.monitor`). Doc oficial:
  https://alejandrominaya.github.io/hyprland-lua-docs/ — sempre conferir antes
  de supor sintaxe.
- **Popups do Quickshell (PopupWindow) precisam de `grabFocus: true`** pra
  aceitar teclado E fechar ao clicar fora. Sem isso, ficam "surdos" a teclado
  por padrão (bug já resolvido, mas documentado aqui pra não reintroduzir).
  NÃO usar `WlrLayershell.keyboardFocus` manual — causou travamento geral da
  barra num teste anterior.
- **`min_size` em window_rule usa formato `"N N"`** (espaço), não `"NxN"`.
- **Workspace ESPECIAL do Hyprland tem bug conhecido** (issue #7998, "not
  planned"): popups/context menus de janelas dentro de workspace especial
  renderizam atrás da janela principal. Por isso a Steam usa workspace normal
  (9), não mais especial.

## Dashboard (clock/painel que abre clicando no relógio) — 100% completo
- ✅ Relógio + data em pt-BR (nomes de dias/meses hardcoded, Qt não localiza)
- ✅ Calendário interativo (navegação de mês)
- ✅ Clima via Open-Meteo (coords de Guaratiba/RJ, sem API key)
- ✅ Player de mídia MPRIS (Quickshell.Services.Mpris) — capa, título, controles
- ✅ Launcher de apps (🔍) — lê `.desktop` files, busca em tempo real, Enter lança
- ✅ Quick toggles Wi-Fi/Bluetooth (nmcli + bluetoothctl)
- ✅ Notificações (NotificationServer, substitui mako) — toast + histórico

## Barra superior (shell.qml) — 100% funcional
Logo Arch + janela ativa | workspaces clicáveis | launcher | wifi toggle |
avisos (notificações) | CPU | RAM | relógio | energia (desligar/reiniciar/logout)

Todos os popups fecham com `grabFocus: true` (clique fora fecha sozinho).

## Dock (quickshell-dock) — 100% funcional
5 ícones: kitty, Floorp, Thunar, VSCode, configurações. Agora é symlink de
verdade (era cópia solta antes).

## Hyprland — extras configurados
- `SUPER+SHIFT+F`: fullscreen real | `SUPER+M`: maximizar
- Steam: workspace 9 dedicado (não mais especial — ver armadilha acima),
  window rule fix pro menu de contexto (`stay_focused` + `min_size = "1 1"`)
- userChrome.css do Floorp com tema vidro (precisa de
  `toolkit.legacyUserProfileCustomizations.stylesheets = true` no about:config)

## Em aberto / possíveis próximos passos
- Nenhum item crítico pendente. Possíveis melhorias futuras: animações de
  transição entre os cards do dashboard, mais quick toggles (brilho, volume),
  suporte a múltiplos monitores (hoje só DP-2 configurado).
