#!/usr/bin/env bash

set -e

echo "Instalando dotfiles..."

# cria pastas necessárias
mkdir -p ~/.config

# HYPRLAND
cp -r .config/hypr ~/.config/

# WAYBAR
cp -r .config/waybar ~/.config/

# WOFi
cp -r .config/wofi ~/.config/

# KITTY
cp -r .config/kitty ~/.config/

# STARSHIP
cp .config/starship.toml ~/.config/ 2>/dev/null || true

# SHELL
cp .zshrc ~/
cp .gitconfig ~/
cp .bashrc ~/

# SCRIPTS
mkdir -p ~/.local/bin
cp -r scripts ~/.local/ 2>/dev/null || true

echo "Concluído!"
