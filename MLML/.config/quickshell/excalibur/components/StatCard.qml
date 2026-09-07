import QtQuick
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: card

    property string label: ""
    property string value: ""
    // 0-1 fraction shown as a bar underneath the value; a negative number
    // hides the bar entirely (used for temperatures, which have no natural
    // 0-1 scale).
    property real percent: -1

    color: Theme.crust
    radius: 10
    implicitHeight: 64

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        Text {
            text: card.label
            color: Theme.subtext0
            font.pixelSize: 11
        }

        Text {
            text: card.value
            color: Theme.text
            font.pixelSize: 18
            font.bold: true
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            visible: card.percent >= 0
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            radius: 2
            color: Theme.surface0

            Rectangle {
                width: parent.width * Math.min(Math.max(card.percent, 0), 1)
                height: parent.height
                radius: 2
                color: Theme.blue
            }
        }
    }
}
