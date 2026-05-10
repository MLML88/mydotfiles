import Quickshell.Hyprland
import QtQuick

import "../components/"

Item {
    id: root

    implicitWidth: Math.min(710, activeWindowText.implicitWidth + 25)
    implicitHeight: 32

    property var currentTitle: Hyprland.activeToplevel?.title ?? "Desktop"

    Pill {
        anchors.fill: parent

        TextField {
            id: activeWindowText

            anchors.centerIn: parent
            width: Math.min(685, implicitWidth)
            elide: Text.ElideRight
            text: root.currentTitle
        }

    }

}
