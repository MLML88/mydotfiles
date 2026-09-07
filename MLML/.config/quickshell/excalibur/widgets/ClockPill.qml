import QtQuick
import "."
import "../themes"
import "../services"

Rectangle {
    id: pill

    // Set by Bar.qml — true only for the monitor Hyprland currently
    // considers focused, so a global Super+Space toggle doesn't pop the
    // launcher open on every monitor at once.
    property bool isFocusedScreen: true

    // Hover shows the calendar, but only when the launcher isn't already
    // open — otherwise moving the mouse across the pill while typing would
    // fight with the launcher for the content area.
    readonly property bool calendarOpen: hover.hovered && !LauncherState.open
    readonly property bool launcherOpen: LauncherState.open && isFocusedScreen
    readonly property bool expanded: calendarOpen || launcherOpen

    readonly property int compactWidth: timeText.implicitWidth + 30
    readonly property int compactHeight: 30

    // Calendar and launcher want different shapes (tall+narrow vs. wide+
    // short), so each mode targets its own size rather than sharing one.
    readonly property int calendarWidth: 360
    readonly property int calendarHeight: 400
    readonly property int launcherWidth: 560
    readonly property int launcherHeight: 300

    readonly property int expandedWidth: launcherOpen ? launcherWidth : calendarWidth
    readonly property int expandedHeight: launcherOpen ? launcherHeight : calendarHeight

    // The underlying window surface is fixed at whichever mode is largest
    // in each dimension (see Bar.qml) — this exposes that max so the
    // surface never has to actually resize, only what's drawn inside it.
    readonly property int maxExpandedWidth: Math.max(calendarWidth, launcherWidth)
    readonly property int maxExpandedHeight: Math.max(calendarHeight, launcherHeight)

    width: expanded ? expandedWidth : compactWidth
    height: expanded ? expandedHeight : compactHeight
    radius: expanded ? 16 : height / 2
    color: Theme.base
    clip: true

    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    HoverHandler {
        id: hover
    }

    Text {
        id: timeText
        anchors.centerIn: parent
        color: Theme.text
        font.pixelSize: 14
        opacity: pill.expanded ? 0 : 1

        Behavior on opacity { NumberAnimation { duration: 120 } }

        function update() {
            text = Qt.formatDateTime(new Date(), "hh:mm AP");
        }

        Component.onCompleted: update()
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: timeText.update()
        }
    }

    Calendar {
        id: calendar
        anchors.fill: parent
        anchors.margins: 14
        opacity: pill.calendarOpen ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    AppLauncher {
        id: appLauncher
        anchors.fill: parent
        anchors.margins: 14
        opacity: pill.launcherOpen ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // Snap the calendar back to today's month once you've moved away, so
    // the next hover always starts from the current date rather than
    // wherever you last browsed to.
    onCalendarOpenChanged: if (!calendarOpen) calendar.resetToToday()

    onLauncherOpenChanged: {
        if (launcherOpen) {
            appLauncher.searchField.forceActiveFocus();
        } else {
            appLauncher.reset();
        }
    }
}
