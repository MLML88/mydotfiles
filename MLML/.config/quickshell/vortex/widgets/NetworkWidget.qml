import Quickshell
import QtQuick
import QtQuick.Layouts

import "../components/"
import "../services/"

Item {
    id: root

    implicitWidth: networkRow.implicitWidth + 25
    implicitHeight: 32

    Pill {
        anchors.fill: parent

        RowLayout {
            id: networkRow
            anchors.centerIn: parent
            spacing: 5

            // Network Icon
            TextField {
                text: Network.getNetworkIcon()
            }

            // Network Name
            TextField {
                text: Network.currentNetwork?.name ?? "Disconnected"
            }

            // Network Strength
            TextField {
                text: `(${Network.signalStrength}%)`
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached(["nm-connection-editor"])
    }
}
