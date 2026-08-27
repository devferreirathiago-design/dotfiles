-- ~/.config/hypr/hyprland.lua
-- Convertido de hyprland.conf (hyprlang) para Lua (Hyprland 0.55+)
-- Gerado com hyprconf2lua e revisado manualmente (correção de aspas em comandos com $(slurp))

local mainMod = "SUPER"

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
        -- Grossura da borda (coloquei 2 para o degradê ficar bem visível)
        border_size = 2,
        col = {
            -- Borda ativa: Degradê Roxo para Rosa em 45 graus (Shinobu)
            active_border   = { colors = { "rgba(cba6f7ff)", "rgba(f5c2e7ff)" }, angle = 45 },
            -- Borda inativa: Um roxo/cinza super escuro e quase transparente
            inactive_border = "rgba(313244aa)",
        },
    },
})

hl.config({
    decoration = {
        rounding = 10,
        blur = {
            enabled        = true,
            size           = 6,
            passes         = 2,
            ignore_opacity = true,
        },
    },
})

------------------------
---- KEYBINDS ----
------------------------

hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
hl.bind(mainMod .. " + " .. "RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd("Floorp"))
hl.bind(mainMod .. " + " .. "C", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + " .. "D", hl.dsp.exec_cmd("wofi --show drun --style ~/.config/wofi/style.css"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("thunar"))
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

------------------------
---- WORKSPACES ----
------------------------

for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

------------------------
---- AUTOSTART ----
------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("kitty")
    hl.exec_cmd("waybar")
    hl.exec_cmd("setsid awww-daemon --format xrgb")
end)
