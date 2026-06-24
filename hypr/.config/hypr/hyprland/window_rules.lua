-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "zen-no-transparent",
    match = { class = "^(zen)$" },
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    name = "zen-pip",
    match = {
        class = "^zen$",
        title = "^Picture-in-Picture$",
    },
    float = true,
    pin = true,
    no_shadow = true,
    no_initial_focus = true,
    size = "(monitor_w*0.25) (monitor_h*0.25)",
    move = "(monitor_w-window_w-20) (monitor_h-window_h-20)",
})
