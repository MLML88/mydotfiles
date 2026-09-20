import QtQuick
import Quickshell
import "../../services"
import "../../config"

Column {
    spacing: Metrics.space1

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExpandedTime
        text: Qt.formatTime(clock.date, "h:mm:ss AP")
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExpandedDate
        text: Qt.formatDate(clock.date, "dddd, MMMM d")
    }
}
