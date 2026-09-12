-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local terminal    = "kitty -o allow_remote_control=yes"
local fileManager = "nautilus"
local menu        = "wofi --show drun"
local browser     = "zen-browser"

local mainMod     = "ALT"

-- General application launch keybinds
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("find_books.sh"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(".config/scripts/theme-switcher/wofi-theme-selector.sh"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(".config/scripts/theme-switcher/wofi-wallpaper-selector.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("kitty yazi ~"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
    { description = "Window: Fullscreen" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -z -m region"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Changing focus binds
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

--#/# bind = SUPER + SHIFT, ←/↑/→/↓,, -- Move in direction
for i = 1, 4 do
    local arrowkey = { "h", "l", "k", "j" }
    local focusdir = { "l", "r", "u", "d" }
    hl.bind(mainMod .. " + SHIFT + " .. arrowkey[i], hl.dsp.window.move({ direction = focusdir[i] }),
        { description = "Window: Move " .. arrowkey[i] })
end

-- Binds for moving windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--# Window split ratio
--#/# binde = SUPER, ;/',, -- Adjust split ratio
-- hl.bind(mainMod .. " + u", hl.dsp.layout("splitratio -0.1"), { repeating = true })
-- hl.bind(mainMod .. " + p", hl.dsp.layout("splitratio +0.1"), { repeating = true })
-- -- Resize active window
-- hl.bind(mainMod .. " + p", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 150 0"))
-- hl.bind(mainMod .. " + u", hl.dsp.exec_cmd("hyprctl dispatch resizeactive -150 0"))
-- hl.bind(mainMod .. " + o", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -150"))
-- hl.bind(mainMod .. " + i", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 150"))

-- Keybinds to use arrows with wasd
hl.bind("SUPER + W", hl.dsp.exec_cmd("wtype -k up"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("wtype -k down"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("wtype -k left"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("wtype -k right"))


-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Handling laptop lid
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("~/.config/scripts/hypr_reload_lid.sh"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("~/.config/scripts/hypr_reload_lid.sh"),
    { locked = true })

-- Media keybinds
local mediaMod = "SUPER"
hl.bind(mediaMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, repeating = true })
hl.bind(mediaMod .. " + N", hl.dsp.exec_cmd("playerctl next"), { repeating = true })
hl.bind(mediaMod .. " + B", hl.dsp.exec_cmd("playerctl previous"), { repeating = true })
hl.bind(mediaMod .. " + U", hl.dsp.exec_cmd("wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 2%-"), { repeating = true })
hl.bind(mediaMod .. " + I", hl.dsp.exec_cmd("wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 2%+"), { repeating = true })
hl.bind(mediaMod .. " + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })

hl.bind(mediaMod .. " + T", hl.dsp.exec_cmd("(pkill potd || true) && (potd &)"), { repeating = false })
hl.bind(mediaMod .. " + SHIFT + T", hl.dsp.exec_cmd("pkill potd || true"), { repeating = false })
