----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    
        disable_hyprland_logo   = true,       
	vrr = false,
	disable_splash_rendering = true,
	bell_sound = "none"
    },
    debug = {
        vfr = false,
        overlay = false
    },

    render = {
        direct_scanout = 0,
        async_commit = true
    },

    cursor = {
        no_hardware_cursors = 0,
	default_monitor = "HDMI-A-2"
    },

    opengl = {
        nvidia_anti_flicker = false,
    },

    ecosystem = {
        no_donation_nag = true
    }
})
