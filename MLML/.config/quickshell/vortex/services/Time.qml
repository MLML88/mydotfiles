pragma Singleton

import Quickshell // for PanelWindow
import QtQuick // for Text

Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm AP")
    }
    readonly property string date: {
        Qt.formatDateTime(clock.date, "ddd MMM dd, yyyy")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
