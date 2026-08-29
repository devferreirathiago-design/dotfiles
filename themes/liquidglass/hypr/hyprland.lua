-- ~/.config/hypr/hyprland.lua
-- Convertido de hyprland.conf (hyprlang) para Lua (Hyprland 0.55+)
-- Gerado com hyprconf2lua e revisado manualmente (correção de aspas em comandos com $(slurp))
-- Atualizado para o tema "liquidglass" (vidro fosco estilo macOS) + novos binds

local mainMod = "SUPER"

------------------------
---- VARIÁVEIS DE AMBIENTE ----
------------------------

-- Correção pra bug conhecido de stutter/freeze em fullscreen com GPUs AMD
-- (conflito entre atomic modesetting do driver e o compositor Wayland)
hl.env("WLR_DRM_NO_ATOMIC", "1")

------------------------
---- MONITOR ----
------------------------

hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@165",
    position = "0x0",
    scale    = 1,
})

------------------------
---- INPUT / LOOK & FEEL ----
------------------------

hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "abnt2",
    },
})

hl.config({
    general = {
        -- Espaçamento entre as janelas (para o papel de parede aparecer mais)
        gaps_in  = 5,
        gaps_out = 10,
        -- Grossura da borda
        border_size = 2,
        col = {
            -- Borda ativa: vidro branco translúcido (tema liquidglass)
            active_border   = { colors = { "rgba(ffffffcc)", "rgba(ffffff66)" }, angle = 45 },
            -- Borda inativa: quase invisível
            inactive_border = "rgba(ffffff22)",
        },
    },
})

hl.config({
    decoration = {
        rounding = 14,
        blur = {
            enabled        = true,
            size           = 6,
            passes         = 2,
            ignore_opacity = true,
        },
    },
})

------------------------
---- LAYER RULES (blur em waybar/wofi) ----
------------------------

hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    match = { namespace = "quickshell-bar" },
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    match = { namespace = "wofi" },
    blur = true,
})

------------------------
---- KEYBINDS ----
------------------------

hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + " .. "N", hl.dsp.exec_cmd("floorp"))
hl.bind(mainMod .. " + " .. "V", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("wofi --show drun --style ~/.config/wofi/style.css"))
hl.bind(mainMod .. " + " .. "F", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("~/scripts/trocar_wallpaper.sh"))

-- Abre o btop flutuante, centralizado e com um tamanho fixo
hl.bind(mainMod .. " + SHIFT + " .. "G", hl.dsp.exec_cmd("kitty --title btop-float -e btop"))

-- Gravar área selecionada (Super + Shift + R)
hl.bind(mainMod .. " + SHIFT + " .. "R", hl.dsp.exec_cmd('wf-recorder -g "$(slurp)" -f ~/Videos/$(date +\'%Y-%m-%d_%H%M%S.mp4\')'))

-- Parar a gravação (Super + Shift + S)
hl.bind(mainMod .. " + SHIFT + " .. "S", hl.dsp.exec_cmd("pkill wf-recorder"))

-- Copiar área selecionada para a área de transferência
hl.bind("SHIFT + " .. "Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Copiar a tela inteira para a área de transferência
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Arrastar janelas com SUPER + Clique Esquerdo
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Redimensionar janelas com SUPER + Clique Direito
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Steam: toggle do workspace especial (esconde/mostra sem fechar)
-- ATENÇÃO: 'toggle_special' ainda não confirmado na doc do hl.dsp.workspace.
-- Se o hyprctl reload reclamar dessa linha, ver alternativas no wiki do Hyprland
-- (ex: hl.dsp.workspace.special("steam") ou sintaxe equivalente do seu parser).
hl.bind(mainMod .. " + " .. "S", hl.dsp.workspace.toggle_special("steam"))

------------------------
---- WORKSPACES ----
------------------------

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + " .. "TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + " .. "TAB", hl.dsp.focus({ workspace = "e-1" }))

------------------------
---- WINDOW RULES ----
------------------------

-- Steam sempre abre direto no workspace especial (fica "escondida" até você chamar com SUPER+S)
hl.window_rule({
    name      = "steam-workspace",
    match     = { class = "^(steam)$" },
    workspace = "special:steam silent",
})

-- Floorp com leve transparência (tema liquidglass)
hl.window_rule({
    name    = "floorp-glass",
    match   = { class = "^(floorp)$" },
    opacity = "0.94 0.88",
})

------------------------
---- AUTOSTART ----
------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("kitty")
    -- hl.exec_cmd("waybar")  -- desativado: substituído pela barra em Quickshell
    hl.exec_cmd("quickshell -c liquidglass")
    hl.exec_cmd("setsid awww-daemon --format xrgb")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("eww open dock")
end)
