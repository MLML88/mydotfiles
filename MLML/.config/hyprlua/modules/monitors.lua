------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Monitor Screen
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@240.30",
    position = "0x0",
    scale    = "1",
})

-- Laptop
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1440@240.00",
    position = "auto",
    scale    = "1.25",
})
hl.monitor({
    output   = "eDP-2",
    mode     = "2560x1440@240.00",
    position = "auto",
    scale    = "1.25",
})

-- workspace = 1, monitor:HDMI-A-1
-- workspace = 2, monitor:HDMI-A-1
-- workspace = 3, monitor:HDMI-A-1
-- workspace = 4, monitor:HDMI-A-1
-- workspace = 5, monitor:HDMI-A-1
--
-- workspace = 6, monitor:eDP-2
-- workspace = 7, monitor:eDP-2
-- workspace = 8, monitor:eDP-2
-- workspace = 9, monitor:eDP-2
-- workspace = 10, monitor:eDP-2
--
for i = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = i < 6 and "HDMI-A-1" or "eDP-2",
        default = (i == 6)
    })
end
