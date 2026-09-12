-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- internal display
hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = 1.0,
})

-- mirroring external displays
-- hl.monitor({
--     output = "HDMI-A-1",
--     mode = "preferred",
--     position = "auto",
--     scale = 1.0,
--     mirror = "eDP-1",
-- })

-- hl.monitor({
--     output = "DP-1",
--     mode = "preferred",
--     position = "auto",
--     scale = 1.0,
--     mirror = "eDP-1",
-- })

-- hl.monitor({
--     output = "DP-2",
--     mode = "preferred",
--     position = "auto",
--     scale = 1.0,
--     mirror = "eDP-1",
-- })
