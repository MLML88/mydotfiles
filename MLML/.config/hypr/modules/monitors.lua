------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Laptop
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60.01",
    position = "0x0",
    scale    = "1",
})
hl.monitor({
    output   = "eDP-2",
    mode     = "2560x1440@240.00",
    position = "0x0",
    scale    = "1.25",
})

-- Monitors
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@240.30",
    position = "auto-left",
    scale    = "1",
})
-- hl.monitor({
--     output   = "HDMI-A-1",
--     mode     = "1920x1080@60.00",
--     position = "0x0",
--     scale    = "1",
-- })

