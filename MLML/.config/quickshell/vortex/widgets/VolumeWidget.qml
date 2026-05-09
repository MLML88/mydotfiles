import Quickshell
import QtQuick
import QtQuick.Layouts

import "../components/"
import "../services/"

Item {
    id: root

    implicitWidth: volumeRow.implicitWidth + 25
    implicitHeight: 32

    Pill {
        anchors.fill: root

        RowLayout {
            id: volumeRow
            anchors.centerIn: parent
            spacing: 5

            // Volume Icon
            TextField {
                text: Volume.getVolumeIcon()
            }

            // Volume Percentage
            TextField {
                visible: !Volume.muted
                text: Volume.getVolumePercent()
            }

            // Bluetooth Icon
            TextField {
                visible: Volume.isBluetooth
                text: "󰂯"
            }
            
            // Bluetooth Battery Icon
            TextField {
                visible: Volume.isBluetooth && Volume.btDevice.batteryAvailable
                text: Volume.getBluetoothIcon()
            }
        }

        DelayHover {
            delayedHover: volumeNamePopup

            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["pavucontrol"])

            onWheel: event => {
                if (!Volume.sink)
                    return

                if (event.angleDelta.y > 0)
                    Volume.vol = Math.min(1.0, Volume.vol + 0.02)
                else
                    Volume.vol = Math.max(0.0, Volume.vol - 0.02)
            }
        }
    }

    // Volume Description Popup
    PopupWindow {
        id: volumeNamePopup

        anchor.item: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height

        implicitWidth: volumeText.implicitWidth + 25
        implicitHeight: root.implicitHeight
        color: "transparent"

        Pill {
            anchors.fill: parent

            TextField {
                id: volumeText
                anchors.centerIn: parent
                text: Volume.sink?.description ?? "No Audio Device"
            }
        }
    }
}
