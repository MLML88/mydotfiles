pragma Singleton
import QtQuick

// Shared across every file that imports this directory (Bar.qml, ClockPill.qml,
// shell.qml's IpcHandler) so the launcher's open/closed state is a single
// source of truth rather than something passed down through properties.
QtObject {
    property bool open: false

    function show() { open = true; }
    function hide() { open = false; }
    function toggle() { open = !open; }
}
