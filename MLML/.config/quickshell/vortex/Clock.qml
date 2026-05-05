import QtQuick

Text {
    property var now: new Date()

    Timer {
        interval: 10000
        running:  true
        repeat:   true
        onTriggered: parent.now = new Date()
    }

    text:           Qt.formatDateTime(now, "ddd dd MMM  hh:mm")
    color:          "#e8e3d8"
    font.family:    "monospace"
    font.pixelSize: 12
}
