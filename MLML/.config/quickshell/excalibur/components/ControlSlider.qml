import QtQuick
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: root

    property string label: ""
    property string valueText: ""
    property real value: 0 // 0-1, reflects external state — this component doesn't own it
    signal adjusted(real v)

    color: Theme.crust
    radius: 10
    implicitHeight: 56

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.label
                color: Theme.text
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: root.valueText
                color: Theme.subtext0
                font.pixelSize: 12
            }
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: 4
            color: Theme.surface0

            function emitFromX(x) {
                root.adjusted(Math.min(Math.max(x / track.width, 0), 1));
            }

            Rectangle {
                width: track.width * Math.min(Math.max(root.value, 0), 1)
                height: parent.height
                radius: 4
                color: Theme.blue
            }

            TapHandler {
                id: tapHandler
                onTapped: track.emitFromX(tapHandler.point.position.x)
            }

            DragHandler {
                id: dragHandler
                target: null
                onCentroidChanged: track.emitFromX(dragHandler.centroid.position.x)
            }
        }
    }
}
