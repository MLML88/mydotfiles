import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import "../widgets"
import "../services"

PanelWindow {
    id: bar

    // Variants creates one Bar per monitor, but LauncherState.open is
    // global — without this, Super+Space would pop the launcher open on
    // every monitor at once instead of just the one you're on.
    readonly property bool isFocusedScreen: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === screen.name

    // Only anchored to the top edge — layer-shell centers an unanchored
    // axis automatically, so leaving left/right unset centers us on screen.
    anchors.top: true
    // Matches Hyprland's gaps_out (15px, see hypr/modules/decorations.lua)
    // so the gap above the pill looks the same as the gap below it.
    margins.top: 8

    // Reserve real screen space equal to the pill's resting (compact)
    // height, so windows tile below it like a normal bar. When it expands
    // to show the calendar, that taller state simply overlays on top of
    // whatever's underneath — same as a real desktop clock flyout.
    exclusiveZone: pill.compactHeight + margins.top
    color: "transparent"

    // `focusable: true` alone only requests "on-demand" focus, which the
    // compositor grants on click rather than automatically — that's why
    // typing didn't work without clicking first. The launcher (always) and
    // the control center (for the Wi-Fi password field) need to grab
    // keyboard input the instant they appear, same as rofi/wofi/fuzzel,
    // which means Exclusive focus specifically while they're open.
    WlrLayershell.keyboardFocus: ((LauncherState.open && isFocusedScreen) || pill.controlCenterOpen) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Fixed at the pill's *expanded* size always — we never resize the
    // actual surface (that's what caused the resize ghosting). Only the
    // Rectangle inside animates; the window is just a static transparent
    // canvas sized to fit the largest state.
    implicitWidth: pill.maxExpandedWidth
    implicitHeight: pill.maxExpandedHeight

    // Restrict input/hit-testing to the pill's current bounds, so the
    // empty transparent space around it doesn't block clicks to windows
    // underneath (e.g. a terminal) when the pill is in its compact state.
    mask: Region {
        item: pill
    }

    ClockPill {
        id: pill
        isFocusedScreen: bar.isFocusedScreen
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
