import QtQuick
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: root

    property string label: ""
    property string status: ""
    property bool checked: false
    signal toggled()
    // Emitted when the label/status area (not the switch) is tapped, to
    // navigate into this section's full picker view.
    signal clicked()

    color: Theme.crust
    radius: 10
    implicitHeight: 56

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.label
                color: Theme.text
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: root.status
                color: Theme.subtext0
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            TapHandler {
                onTapped: root.clicked()
            }
        }

        Text {
            text: "›"
            color: Theme.overlay1
            font.pixelSize: 15
        }

        Rectangle {
            id: track
            Layout.preferredWidth: 40
            Layout.preferredHeight: 22
            radius: height / 2
            color: root.checked ? Theme.blue : Theme.surface0

            Behavior on color { ColorAnimation { duration: 120 } }

            Rectangle {
                width: 18
                height: 18
                radius: 9
                color: Theme.base
                anchors.verticalCenter: parent.verticalCenter
                x: root.checked ? parent.width - width - 2 : 2

                Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }

            TapHandler {
                onTapped: root.toggled()
            }
        }
    }
}
