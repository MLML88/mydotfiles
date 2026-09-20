import Quickshell // for Text
import QtQuick

PanelWindow {
    id: bar

    anchors.top: true

    margins.top: 8

    implicitHeight: 35
    color: "transparent"

    // Clock
    Rectangle {
        radius: 15
        anchors.fill: parent

        Text {
            anchors.centerIn: parent
            text: "hello"
        }
    }

}