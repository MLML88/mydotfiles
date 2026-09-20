import QtQuick

// Not a singleton: each monitor's window owns its own instance so expanding the notch
// on one screen never affects another screen's notch.
QtObject {
    readonly property string idle: "idle"
    readonly property string clock: "clock"
    readonly property string calendar: "calendar"
    readonly property string launcher: "launcher"
    readonly property string media: "media"
    readonly property string stats: "stats"
    readonly property string control: "control"
    readonly property string notification: "notification"

    property string current: idle
    // State to return to once an interrupting notification is dismissed.
    property string previous: idle

    function expand(state) {
        if (state === idle) return;
        if (state === notification) {
            if (current !== notification) previous = current;
        } else if (current === notification) {
            return; // an active notification takes priority until it's dismissed
        }
        current = state;
    }

    function collapse() {
        if (current === notification) {
            current = previous;
            previous = idle;
        } else {
            current = idle;
        }
    }

    function toggle(state) {
        if (current === state) collapse();
        else expand(state);
    }
}
