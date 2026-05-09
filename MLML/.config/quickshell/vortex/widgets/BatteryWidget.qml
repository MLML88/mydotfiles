import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

import "../components/"
import "../services/"

Item {
    id: root

    implicitWidth: batteryRow.implicitWidth + 25
    implicitHeight: 32

    Pill {
        anchors.fill: root

        RowLayout {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 3

            // Charging Icon
            TextField {
                visible: Battery.battery.state === UPowerDeviceState.Charging
                text: "󱐋"
            }

            // Battery Icon
            TextField {
                text: Battery.getBatteryIcon()
            }

            // Battery Percentage
            TextField {
                text: Battery.battery ? (Battery.battery.percentage * 100) + "%" : "--%"
            }

        }
        // Hover charging state/remainging time
        DelayHover {
            delayedHover: batteryPopup
        }
    }

    // Battery State Popup
    PopupWindow {
        id: batteryPopup

        anchor.item: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height

        implicitWidth: stateText.implicitWidth + 25
        implicitHeight: root.height * 0.85
        color: "transparent"

        Pill {
            anchors.fill: parent

            TextField {
                id: stateText
                anchors.centerIn: parent
                text: Battery.getBatteryState()
            }
        }
    }
}
