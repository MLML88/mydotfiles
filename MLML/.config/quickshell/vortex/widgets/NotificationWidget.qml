import QtQuick

import "../components/"
import "../themes/"

Item {
    id: root

    implicitWidth: icon.implicitWidth + 25
    implicitHeight: 32

    Pill {
        anchors.fill: parent

        TextField {
            id: icon
            anchors.centerIn: parent
            text: ""
            font.pixelSize: TokyoNight.pixelSize
        }
    }
}
