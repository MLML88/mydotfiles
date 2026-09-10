//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import "modules"
import "services"

ShellRoot {
    // `qs -c excalibur ipc call launcher toggle` (e.g. from a Hyprland
    // keybind) invokes this, which just flips the shared open/closed flag
    // that ClockPill watches. Opening one of launcher/dashboard/control
    // center closes the other two, since the pill can only show one
    // expanded mode at a time.
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            LauncherState.toggle();
            if (LauncherState.open) {
                DashboardState.hide();
                ControlCenterState.hide();
            }
        }
    }

    // `qs -c excalibur ipc call dashboard toggle`
    IpcHandler {
        target: "dashboard"

        function toggle(): void {
            DashboardState.toggle();
            if (DashboardState.open) {
                LauncherState.hide();
                ControlCenterState.hide();
            }
        }
    }

    // `qs -c excalibur ipc call controlcenter toggle`
    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            ControlCenterState.toggle();
            if (ControlCenterState.open) {
                LauncherState.hide();
                DashboardState.hide();
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
