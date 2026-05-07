import QtQuick

import "../components/"
import "../themes/"

Item {
    id: root

    implicitWidth: 40
    implicitHeight: 32

    Pill {
        anchors.fill: parent

        Text {
            anchors.centerIn: parent
            text: "󰣇"
            color: TokyoNight.textCol
            font {
                pixelSize: TokyoNight.pixelSize + 5
                family: TokyoNight.family
            }
        }
    }
}
