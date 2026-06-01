-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function () 
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("blueman-applet")
    -- hl.exec_cmd("waybar")
    hl.exec_cmd("qs -c vortex > ~/.cache/quickshell/quickshell.log 2>&1 &")
    hl.exec_cmd("hyprsunset -t 4500")

    hl.exec_cmd("swaync")

    hl.exec_cmd("wl-paste --type text --watch cliphist store # Stores only text data")
    hl.exec_cmd("wl-paste --type image --watch cliphist store # Stores only image data")

    hl.exec_cmd("wl-clip-persist --clipboard regular")

    hl.exec_cmd("fcitx5")
end)

