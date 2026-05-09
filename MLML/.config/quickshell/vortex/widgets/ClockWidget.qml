import Quickshell
import QtQuick

import "../services/"
import "../components/"

Item {
    id: root

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

        DelayHover {
            delayedHover: datePopup
        }
    }

    // Date Popup
    PopupWindow {
        id: datePopup

        anchor.item: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height

        implicitWidth: dateText.implicitWidth + 25
        implicitHeight: root.implicitHeight
        color: "transparent"

        Pill {
            anchors.fill: parent

            TextField {
                id: dateText
                anchors.centerIn: parent
                text: Time.date
            }
        }
    }
}
