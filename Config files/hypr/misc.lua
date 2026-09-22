----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true,-- If true disables the random hyprland logo / anime girl background. :(
        vrr = false
    },
    debug = {
        vfr = true,
        overlay = false
    },
    render = {
        direct_scanout = 2,
        --async_commit = true
    },
    cursor = {
        no_hardware_cursors = 0,
	default_monitor = "HDMI-A-22"
    },
    opengl = {
        nvidia_anti_flicker = true,
    }
})
