//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import "modules"
import "services"

ShellRoot {
    // `qs -c excalibur ipc call launcher toggle` (e.g. from a Hyprland
    // keybind) invokes this, which just flips the shared open/closed flag
    // that ClockPill watches.
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            LauncherState.toggle();
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
