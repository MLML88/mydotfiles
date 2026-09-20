import QtQuick
import Quickshell
import "../../services"

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeIdle
        text: Qt.formatTime(clock.date, "h:mm AP")
    }
}
