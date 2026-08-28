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
