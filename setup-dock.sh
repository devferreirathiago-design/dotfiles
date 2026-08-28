#!/usr/bin/env bash
#
# setup-dock.sh — instala o eww (se preciso) e integra o dock estilo macOS
# ao tema liquidglass.
#
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
THEME_DIR="$DOTFILES_DIR/themes/liquidglass"
EWW_THEME_DIR="$THEME_DIR/eww"
EWW_CONFIG_DIR="$HOME/.config/eww"

echo ">> Verificando se o eww está instalado..."
if ! command -v eww &>/dev/null; then
    echo "   eww não encontrado. Instalando via pacman..."
    sudo pacman -S --needed eww
else
    echo "   eww já instalado, ok."
fi

echo ">> Criando pasta do dock dentro do tema liquidglass..."
mkdir -p "$EWW_THEME_DIR"

# Os arquivos eww.yuck e eww.scss precisam estar em ~/dotfiles/themes/liquidglass/eww/
# (baixe-os separadamente e coloque nessa pasta antes de rodar este script,
#  ou rode o script depois de tê-los movido pra lá)
if [[ ! -f "$EWW_THEME_DIR/eww.yuck" || ! -f "$EWW_THEME_DIR/eww.scss" ]]; then
    echo "   aviso: eww.yuck e/ou eww.scss não encontrados em $EWW_THEME_DIR"
    echo "   Baixe os dois arquivos e mova pra essa pasta antes de continuar:"
    echo "     mv ~/Downloads/eww.yuck ~/Downloads/eww.scss $EWW_THEME_DIR/"
    echo "   Depois rode este script de novo."
    exit 1
fi

echo ">> Linkando configuração do eww..."
mkdir -p "$EWW_CONFIG_DIR"
ln -sfn "$EWW_THEME_DIR/eww.yuck" "$EWW_CONFIG_DIR/eww.yuck"
ln -sfn "$EWW_THEME_DIR/eww.scss" "$EWW_CONFIG_DIR/eww.scss"
echo "   linkado: $EWW_CONFIG_DIR/eww.yuck -> $EWW_THEME_DIR/eww.yuck"
echo "   linkado: $EWW_CONFIG_DIR/eww.scss -> $EWW_THEME_DIR/eww.scss"

echo ">> Reiniciando o daemon do eww..."
eww kill 2>/dev/null || true
sleep 0.5
eww daemon
sleep 0.5
eww open dock

echo ""
echo ">> Dock ativado!"
echo ""
echo "IMPORTANTE — passos manuais que ainda faltam:"
echo "  1. Adicione o eww ao autostart do hyprland.lua (dentro do hl.on('hyprland.start', ...)):"
echo "       hl.exec_cmd('eww daemon')"
echo "       hl.exec_cmd('eww open dock')"
echo ""
echo "  2. Adicione blur pro dock no hyprland.lua (namespace do eww costuma ser 'eww-dock'):"
echo "       hl.layer_rule({ match = { namespace = \"eww-dock\" }, blur = true })"
echo ""
echo "  3. Se os ícones (Nerd Font) não aparecerem, instale:"
echo "       sudo pacman -S ttf-jetbrains-mono-nerd"
