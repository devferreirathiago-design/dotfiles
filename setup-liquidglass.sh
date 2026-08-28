#!/usr/bin/env bash
#
# setup-liquidglass.sh — monta o tema "liquidglass" (vidro fosco estilo macOS Tahoe)
# com workspaces dinâmicos centralizados, sem bateria (desktop), player de mídia
# via mpris, e aplica os keybinds combinados.
#
# Uso: ./setup-liquidglass.sh
#
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
THEME_DIR="$DOTFILES_DIR/themes/liquidglass"
CONFIG_DIR="$HOME/.config"

echo ">> Criando estrutura de pastas do tema liquidglass..."
mkdir -p "$THEME_DIR"/{hypr,waybar,kitty,wofi}

# --- 1. Copia o hyprland.lua atual como base ---
if [[ -f "$CONFIG_DIR/hypr/hyprland.lua" ]]; then
    cp "$CONFIG_DIR/hypr/hyprland.lua" "$THEME_DIR/hypr/hyprland.lua"
    echo "   hyprland.lua copiado como base"
else
    echo "   aviso: ~/.config/hypr/hyprland.lua não encontrado, criando vazio"
    touch "$THEME_DIR/hypr/hyprland.lua"
fi

# --- 2. Arquivo separado de binds — dá pra 'require' dele no hyprland.lua principal ---
cat > "$THEME_DIR/hypr/binds.lua" << 'EOF'
-- binds.lua — keybinds combinados (tema liquidglass)
-- Adicione 'local binds = require("binds")' (ou o caminho equivalente) no hyprland.lua

local mod = "SUPER"

return {
    -- Workspaces
    { mod, "1", "workspace", "1" },
    { mod, "2", "workspace", "2" },
    { mod, "3", "workspace", "3" },
    { mod, "4", "workspace", "4" },
    { mod, "5", "workspace", "5" },
    { mod, "6", "workspace", "6" },
    { mod, "7", "workspace", "7" },
    { mod, "8", "workspace", "8" },
    { mod, "9", "workspace", "9" },

    { mod, "TAB", "workspace", "e+1" },
    { mod .. " SHIFT", "TAB", "workspace", "e-1" },

    -- Apps
    { mod, "N", "exec", "floorp" },
    { mod, "T", "exec", "kitty" },
    { mod, "E", "exec", "wofi --show drun" },
    { mod, "Q", "killactive", "" },
    { mod, "V", "exec", "code" },
    { mod, "W", "exec", "~/dotfiles/scripts/trocar_wallpaper.sh" },

    -- Steam (scratchpad)
    { mod, "S", "togglespecialworkspace", "steam" },
}

-- Regra de janela p/ Steam sempre abrir no workspace especial (adicionar via windowrulev2):
-- windowrulev2 = workspace special:steam silent, class:^(steam)$
EOF
echo "   hypr/binds.lua criado (verifique a sintaxe do seu parser Lua específico antes de aplicar)"

# --- 3. waybar/config — layout: app à esquerda, workspaces centralizados, status à direita ---
cat > "$THEME_DIR/waybar/config" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 34,
    "margin-top": 0,
    "modules-left": ["hyprland/window"],
    "modules-center": ["hyprland/workspaces"],
    "modules-right": ["mpris", "network", "pulseaudio", "clock"],

    "hyprland/window": {
        "format": "{}",
        "max-length": 30,
        "separate-outputs": true
    },

    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "persistent-workspaces": {},
        "all-outputs": false
    },

    "mpris": {
        "format": "  {title}",
        "format-paused": "  {title}",
        "max-length": 20,
        "on-click": "playerctl play-pause"
    },

    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "  Conectado",
        "format-disconnected": "  Sem rede",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}"
    },

    "pulseaudio": {
        "format": "{icon}  {volume}%",
        "format-muted": "  Mudo",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },

    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%A, %d de %B}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    }
}
EOF
echo "   waybar/config criado (sem módulo de bateria — comente/descomente módulos direto aqui pra ajustar o que aparece)"

# --- 4. waybar/style.css — vidro fosco estilo Liquid Glass ---
cat > "$THEME_DIR/waybar/style.css" << 'EOF'
* {
    font-family: "SF Pro Display", "Inter", "JetBrainsMono Nerd Font", sans-serif;
    font-size: 12px;
    font-weight: 600;
}

window#waybar {
    background: linear-gradient(180deg, rgba(255,255,255,0.58), rgba(255,255,255,0.40));
    color: #101012;
    border-bottom: 1px solid rgba(255,255,255,0.55);
}

#window,
#mpris,
#network,
#pulseaudio,
#clock {
    padding: 0 12px;
    color: #101012;
}

#workspaces {
    background: rgba(255,255,255,0.30);
    border-radius: 999px;
    padding: 3px;
    margin: 4px 0;
}

#workspaces button {
    color: #161618;
    background: transparent;
    border-radius: 50%;
    min-width: 24px;
    padding: 0;
    margin: 0 2px;
}

#workspaces button.active {
    background: linear-gradient(160deg, #3d3d3f, #0a0a0c);
    color: #ffffff;
}

#pulseaudio.muted {
    color: #c8382e;
}

#network.disconnected {
    color: #c8382e;
}
EOF
echo "   waybar/style.css criado"

# --- 5. wofi/style.css — vidro fosco combinando ---
cat > "$THEME_DIR/wofi/style.css" << 'EOF'
window {
    background: linear-gradient(165deg, rgba(255,255,255,0.55), rgba(255,255,255,0.30));
    border: 1px solid rgba(255,255,255,0.6);
    border-radius: 22px;
}

#input {
    background: rgba(255,255,255,0.35);
    color: #101012;
    border: 1px solid rgba(255,255,255,0.4);
    border-radius: 999px;
    margin: 10px;
    padding: 6px 14px;
    font-weight: 600;
}

#entry {
    color: #101012;
    padding: 8px 12px;
    border-radius: 12px;
    font-weight: 500;
}

#entry:selected {
    background: rgba(255,255,255,0.4);
}
EOF
echo "   wofi/style.css criado"

# --- 6. kitty.conf — combina com o vidro (fundo translúcido + blur do compositor) ---
cat > "$THEME_DIR/kitty/kitty.conf" << 'EOF'
# Tema Liquid Glass — kitty com fundo translúcido

background            #1c1c1e
foreground            #f2f2f2
cursor                #c8382e
selection_background  #3a3a3c
selection_foreground  #f2f2f2

background_opacity    0.75
dynamic_background_opacity yes

color0   #1c1c1e
color8   #3a3a3c
color1   #c8382e
color9   #ff5f57
color2   #28c840
color10  #6bf088
color3   #febc2e
color11  #ffdb7a
color4   #2f7fd6
color12  #74c2f7
color5   #a855f7
color13  #c98bff
color6   #3a94d8
color14  #82caf0
color7   #f2f2f2
color15  #ffffff

font_family      JetBrainsMono Nerd Font
window_padding_width 8
EOF
echo "   kitty/kitty.conf criado"

echo ""
echo ">> Tema liquidglass montado em: $THEME_DIR"
echo ""
echo "IMPORTANTE — passos manuais antes de ativar:"
echo "  1. Confirme se o 'blur' está habilitado no hyprland.lua (decoration { blur { enabled = true } })"
echo "     e adicione regra de blur pra waybar/wofi/kitty se ainda não tiver."
echo "  2. Adicione a windowrulev2 da Steam manualmente no hyprland.lua (está comentada em binds.lua)."
echo "  3. Confirme se 'playerctl' e 'pavucontrol' estão instalados:"
echo "       sudo pacman -S playerctl pavucontrol"
echo ""
echo "Próximo passo: rode o switch-theme.sh para ativar."
echo "  cd ~/dotfiles && ./switch-theme.sh liquidglass"
