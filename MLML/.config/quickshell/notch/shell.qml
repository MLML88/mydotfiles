import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "./config"
import "./services"
import "./components"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            WlrLayershell.namespace: "quickshell:notch"
            WlrLayershell.layer: WlrLayer.Overlay
            focusable: NotchState.current !== NotchState.idle
            WlrLayershell.keyboardFocus: focusable ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            // Only the pill itself is clickable while idle so the rest of the
            // screen passes clicks through; once expanded the whole window
            // catches clicks so clicking anywhere outside the pill collapses it.
            mask: Region {
                item: NotchState.current === NotchState.idle ? pill : catcher
            }

            Item {
                id: catcher
                anchors.fill: parent
                focus: window.focusable
                Keys.onEscapePressed: NotchState.collapse()

                MouseArea {
                    anchors.fill: parent
                    onClicked: NotchState.collapse()
                }
            }

            Pill {
                id: pill
                anchors.top: parent.top
                anchors.topMargin: Metrics.topMargin
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    IpcHandler {
        target: "notch"

        function toggle(state: string): void { NotchState.toggle(state); }
        function expand(state: string): void { NotchState.expand(state); }
        function collapse(): void { NotchState.collapse(); }
    }

    GlobalShortcut {
        name: "toggle-clock"
        description: "Expand or collapse the Notch clock view"
        onPressed: NotchState.toggle(NotchState.clock)
    }
}
