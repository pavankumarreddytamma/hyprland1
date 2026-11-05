---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "rofi -show drun"
local broswer     = "google-chrome-stable"

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + C", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo())
hl.bind("SUPER + V", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left"}))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up"}))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down"}))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right"}))
hl.bind("SUPER + R", hl.dsp.exec_cmd(broswer))
hl.bind("SUPER + W", hl.dsp.exec_cmd("/home/pavan/Scripts/awww.sh"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER  + S", hl.dsp.exec_cmd("HYPRSHOT_DIR=/home/pavan/screenshots hyprshot --freeze -zm region"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("brave"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("pavucontrol"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd("blueman-manager"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("gnome-calculator"))

hl.bind("SUPER + H",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind("SUPER + GRAVE",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + GRAVE", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
