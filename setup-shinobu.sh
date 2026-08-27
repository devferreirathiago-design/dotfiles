#!/usr/bin/env bash
#
# setup-shinobu.sh — monta o tema "shinobu" do zero, com a paleta roxo/magenta,
# e já deixa ativo via symlink.
#
# Uso: ./setup-shinobu.sh
#
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
THEME_DIR="$DOTFILES_DIR/themes/shinobu"
CONFIG_DIR="$HOME/.config"

echo ">> Criando estrutura de pastas do tema shinobu..."
mkdir -p "$THEME_DIR"/{hypr,waybar,kitty,wofi}

# --- 1. Copia o hyprland.lua atual como base (se existir) ---
if [[ -f "$CONFIG_DIR/hypr/hyprland.lua" ]]; then
    cp "$CONFIG_DIR/hypr/hyprland.lua" "$THEME_DIR/hypr/hyprland.lua"
    echo "   hyprland.lua copiado como base (edite as cores de borda manualmente, ver README)"
else
    echo "   aviso: ~/.config/hypr/hyprland.lua não encontrado, pulando"
fi

# --- 2. waybar/style.css com paleta shinobu ---
cat > "$THEME_DIR/waybar/style.css" << 'EOF'
@define-color base       #0d0a14;
@define-color surface    #2a1a40;
@define-color primary    #8b5cf6;
@define-color accent     #d946ef;
@define-color text       #e9d5ff;
@define-color text-dim   #a78bca;
@define-color border     #c026d3;
@define-color urgent     #f472b6;

* {
    font-family: "JetBrainsMono Nerd Font", sans-serif;
    font-size: 13px;
}

window#waybar {
    background-color: alpha(@base, 0.85);
    color: @text;
    border-bottom: 2px solid @border;
}

#workspaces button {
    color: @text-dim;
    background: transparent;
    padding: 0 8px;
}

#workspaces button.active {
    color: @accent;
    background: alpha(@primary, 0.2);
    border-radius: 8px;
}

#clock, #cpu, #memory, #pulseaudio, #battery, #tray {
    color: @text;
    background: alpha(@surface, 0.6);
    padding: 0 10px;
    margin: 2px 3px;
    border-radius: 8px;
}

#pulseaudio, #battery {
    color: @accent;
}
EOF
echo "   waybar/style.css criado"

# --- 3. Copia o waybar/config atual como base (layout não muda, só cor) ---
if [[ -f "$CONFIG_DIR/waybar/config" ]]; then
    cp "$CONFIG_DIR/waybar/config" "$THEME_DIR/waybar/config"
    echo "   waybar/config copiado como base"
else
    echo "   aviso: ~/.config/waybar/config não encontrado, pulando"
fi

# --- 4. wofi/style.css com paleta shinobu ---
cat > "$THEME_DIR/wofi/style.css" << 'EOF'
window {
    background-color: alpha(#0d0a14, 0.92);
    border: 2px solid #c026d3;
    border-radius: 12px;
}

#input {
    background-color: #2a1a40;
    color: #e9d5ff;
    border: 1px solid #8b5cf6;
    border-radius: 8px;
    margin: 8px;
}

#entry {
    color: #e9d5ff;
    padding: 6px;
}

#entry:selected {
    background-color: alpha(#8b5cf6, 0.35);
    border-radius: 8px;
}

#text:selected {
    color: #d946ef;
}
EOF
echo "   wofi/style.css criado"

# --- 5. kitty.conf com paleta shinobu ---
cat > "$THEME_DIR/kitty/kitty.conf" << 'EOF'
# Tema Shinobu — roxo/magenta neon

background            #0d0a14
foreground            #e9d5ff
cursor                #d946ef
selection_background  #8b5cf6
selection_foreground  #0d0a14

# black
color0   #1a0f2e
color8   #2a1a40

# red
color1   #f472b6
color9   #f472b6

# green
color2   #a78bca
color10  #c4a8e0

# yellow
color3   #d946ef
color11  #e879f9

# blue
color4   #8b5cf6
color12  #a78bfa

# magenta
color5   #c026d3
color13  #e879f9

# cyan
color6   #8b5cf6
color14  #a78bfa

# white
color7   #e9d5ff
color15  #ffffff

background_opacity    0.90
EOF
echo "   kitty/kitty.conf criado"

echo ""
echo ">> Tema shinobu montado em: $THEME_DIR"
echo ""
echo "Próximo passo: rode o switch-theme.sh para ativar."
echo "  cd ~/dotfiles && ./switch-theme.sh shinobu"
