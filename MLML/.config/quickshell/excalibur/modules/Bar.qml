import Quickshell // for Text
import QtQuick

import "../services/"
import "../themes/"

PanelWindow {
    id: bar

    anchors.top: true

    margins.top: 10
    margins.bottom: 5

    implicitWidth: clock.implicitWidth + 60
    implicitHeight: 35
    color: "transparent"

    // Clock
    Rectangle {
        radius: 15
        anchors.fill: parent
        color: TokyoNight.background

        Text {
            id: clock
            anchors.centerIn: parent
            text: Time.time
            color: TokyoNight.textCol
            font {
                pixelSize: TokyoNight.pixelSize
                family: TokyoNight.family
                weight: TokyoNight.weight
            }
        }
    }

}