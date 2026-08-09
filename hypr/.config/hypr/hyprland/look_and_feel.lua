-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
local colors = require("hyprland.hypr-colors")

-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = 10,
        -- gaps_out         = 15,
        -- gaps_in          = { top = 10, right = 10, bottom = 5, left = 10 },
        -- gaps_out         = { top = 2, right = 10, bottom = 10, left = 10 }, -- used to be
        gaps_out         = { top = 3, right = 15, bottom = 15, left = 15 },

        border_size      = 3,
        col              = {
            active_border   = colors.base0D,
            inactive_border = colors.base03,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "master",
    },

    decoration = {
        rounding         = 12,
        rounding_power   = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur             = {
            enabled  = true,
            size     = 1,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- -- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
-- hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1.0, stiffness = 171.2633, dampening = 15.8273644 })

hl.animation({ leaf = "workspaces", enabled = true, speed = 0.50, bezier = "easeOutQuint", style = "fade" })
-- hl.animation({ leaf = "windows", enabled = true, speed = 1.00, bezier = "almostLinear" })
hl.animation({ leaf = "windows", enabled = true, speed = 1.00, spring = "easy" })
hl.animation({ leaf = "fade", enabled = true, speed = 0.50, bezier = "quick" })


-- hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "default" })
-- hl.animation({ leaf = "border", enabled = true, speed = 2.39, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windows", enabled = true, speed = 1.79, spring = "easy" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.1, spring = "easy", style = "popin 87%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
-- hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
-- hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesIn", enabled = true, speed = 0.8, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 0.8, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "slave",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo   = true,
    },
})
