import QtQuick
import QtQuick.Layouts
import "../themes"

// A single row in a picker list (Wi-Fi network, Bluetooth device): a title,
// a short status on the right, and a highlight when it's the active one.
Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal activated()

    implicitHeight: 32
    radius: 6
    color: active ? Theme.surface0 : (hoverHandler.hovered ? Theme.surface0 : "transparent")

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Text {
            text: root.title
            color: Theme.text
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: root.subtitle
            color: Theme.subtext0
            font.pixelSize: 10
        }
    }

    HoverHandler { id: hoverHandler }
    TapHandler { onTapped: root.activated() }
}
