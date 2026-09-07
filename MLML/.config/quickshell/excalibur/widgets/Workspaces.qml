import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../themes"

RowLayout {
    spacing: 4

    Repeater {
        // Hyprland.workspaces is a live ObjectModel of HyprlandWorkspace —
        // it updates itself as you create/destroy/switch workspaces.
        model: Hyprland.workspaces

        Rectangle {
            required property var modelData
            property bool active: Hyprland.focusedWorkspace?.id === modelData.id

            implicitWidth: 22
            implicitHeight: 22
            radius: 6
            color: active ? Theme.blue : Theme.surface0

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: active ? Theme.base : Theme.text
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
