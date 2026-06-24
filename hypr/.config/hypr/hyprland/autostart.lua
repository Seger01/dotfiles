-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
local colors = require("hyprland.hypr-colors")

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("sh -c 'sleep 2 && hyprctl hyprpaper wallpaper , " .. colors.image .. "'")
    -- hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\"")
    hl.exec_cmd("lights off")
end)
