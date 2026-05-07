import Quickshell
import QtQuick

import "../services/"
import "../components/"
import "../themes/"

Item {
    id: root

    property bool popupOpen: false

    implicitWidth: 100
    implicitHeight: 32

    Pill {
        anchors.fill: root

        // Clock
        Text {
            anchors.centerIn: parent
            color: TokyoNight.textCol
            font {
                pixelSize: TokyoNight.pixelSize
                weight: TokyoNight.weight
                family: TokyoNight.family
            }
            text: Time.time
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: root.popupOpen = true
            onExited: root.popupOpen = false
        }
    }

    // Date popup
    PopupWindow {
        anchor.item: root

        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height

        width: 160
        height: root.height * 0.85
        color: "transparent"
        visible: root.popupOpen

        Pill {
            anchors.fill: parent

            Text {
                anchors.centerIn: parent
                color: TokyoNight.textCol
                font {
                    pixelSize: 16
                    weight: 650
                    family: "Rubik"
                }
                text: Time.date
            }
        }
    }
}
