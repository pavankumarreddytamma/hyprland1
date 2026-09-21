-----------------------
---- LOOK AND FEEL ----
-----------------------


hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 12,

        border_size = 0,

        col = {
            active_border   = { colors = {"rgb(db74bd)", "rgb(8c0464)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,


        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 8,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 8,
            passes    = 3,
            new_optimizations = true,
        },

        motion_blur = {
            enabled = false,
            samples = 12,
        },
    },

    animations = {
        enabled = true,
    },
})


hl.curve("animation", {type = "bezier",points = {{0, 0},{0.3, 1},}})
hl.curve("animation2", {type = "bezier", points = {{0.18, 1.35}, {0.40, 1.00},}})
hl.curve("animation3", {type = "bezier", points = {{0.12, 0.82}, {0.28, 1.00},}})
hl.curve("animation4", {type = "bezier", points = {{0.16, 0.78}, {0.24, 1.00},}})
hl.curve("animation5", {type = "bezier", points = {{0.25, 0.70}, {0.15, 1.00},}})
hl.curve("animation6", {type = "bezier", points = {{0.33, 0.00}, {0.67, 1.00},}})
hl.curve("animation6", {type = "bezier", points = {{0.10, 0.90}, {0.25, 1.00},}})


hl.animation({ leaf = "global",        enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 5, bezier = "animation6"})
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 5, bezier = "animation6", style = "slide"})
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 5, bezier = "animation6", style = "slide"})
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 5, bezier = "animation6", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 5, bezier = "animation6", style = "slide" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 5, bezier = "animation6" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 5, bezier = "animation6", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 5, bezier = "animation6", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 5, bezier = "animation6", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 5, bezier = "animation6" })

hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})


hl.config({
    master = {
        new_status = "master",
    },
})


hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})
