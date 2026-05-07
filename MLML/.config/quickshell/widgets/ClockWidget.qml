import Quickshell
import QtQuick

import "../services/"
import "../components/"

Item {
    id: root

    property bool popupOpen: false

    implicitWidth: clock.implicitWidth + 25
    implicitHeight: 32

    Pill {
        anchors.fill: root

        // Clock
        TextField {
            id: clock
            anchors.centerIn: parent
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

        implicitWidth: 160
        implicitHeight: root.height * 0.85
        color: "transparent"
        visible: root.popupOpen

        Pill {
            anchors.fill: parent

            TextField {
                anchors.centerIn: parent
                text: Time.date
            }
        }
    }
}
