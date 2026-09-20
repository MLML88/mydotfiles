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

            // Only the strip + notch's own visible area is clickable; the transparent space
            // beside the notch (within this window's full width/height) passes clicks
            // through to whatever's underneath. Pill's own bounding box can't be used
            // directly since it also spans that transparent space.
            mask: Region {
                x: 0; y: 0
                width: pill.width; height: pill.stripHeight
                Region {
                    x: pill.notchLeft; y: pill.notchTop
                    width: pill.notchWidth; height: pill.notchBodyHeight
                    radius: pill.bottomRadius
                    intersection: Intersection.Combine
                }
            }

            Pill {
                id: pill
                notchState: window.notchState
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
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
