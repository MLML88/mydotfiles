import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "./config"
import "./services"
import "./components"

ShellRoot {
    Variants {
        id: notchWindows
        model: Quickshell.screens

        PanelWindow {
            id: window
            property var modelData
            screen: modelData
            // Each monitor owns its own state, so expanding on one screen's notch never
            // expands another screen's.
            property NotchState notchState: NotchState {}

            // Only anchored to the top edge: this reserves real screen space (below) for
            // other windows instead of a full-screen overlay, so the notch never sits on
            // top of app content. The window itself stays tall enough to fit any expanded
            // view; exclusiveZone below is a fixed, smaller amount so expanding doesn't
            // shove other windows around every time the pill grows.
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Metrics.windowHeight
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: Metrics.reservedHeight
            color: "transparent"

            WlrLayershell.namespace: "quickshell:notch"
            WlrLayershell.layer: WlrLayer.Overlay
            focusable: notchState.current !== notchState.idle
            WlrLayershell.keyboardFocus: focusable ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            // Only the pill itself is clickable; the rest of this window's width/height
            // (needed to fit expanded content and span the screen for centering) passes
            // clicks through to whatever's underneath.
            mask: Region {
                item: pill
            }

            Pill {
                id: pill
                notchState: window.notchState
                anchors.top: parent.top
                anchors.topMargin: Metrics.topMargin
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // IPC and the global shortcut aren't tied to a specific monitor, so they act on every
    // screen's notch at once.
    IpcHandler {
        target: "notch"

        function toggle(state: string): void {
            for (const win of notchWindows.instances) win.notchState.toggle(state);
        }
        function expand(state: string): void {
            for (const win of notchWindows.instances) win.notchState.expand(state);
        }
        function collapse(): void {
            for (const win of notchWindows.instances) win.notchState.collapse();
        }
    }

    GlobalShortcut {
        name: "toggle-clock"
        description: "Expand or collapse the Notch clock view"
        onPressed: {
            for (const win of notchWindows.instances) win.notchState.toggle(win.notchState.clock);
        }
    }
}
