import QtQuick
import QtQuick.Layouts
import "../themes"

// Back arrow + title, used atop the Wi-Fi/Bluetooth full-view pickers.
RowLayout {
    id: root

    property string title: ""
    signal back()

    spacing: 8

    Rectangle {
        implicitWidth: 28
        implicitHeight: 28
        radius: 8
        color: hoverHandler.hovered ? Theme.surface0 : "transparent"

        Text {
            anchors.centerIn: parent
            text: "‹"
            color: Theme.subtext0
            font.pixelSize: 16
        }

        HoverHandler { id: hoverHandler }
        TapHandler { onTapped: root.back() }
    }

    Text {
        text: root.title
        color: Theme.text
        font.pixelSize: 14
        font.bold: true
        Layout.fillWidth: true
    }
}
