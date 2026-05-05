import QtQuick
import Quickshell.Hyprland

Rectangle {
    required property var workspace

    property bool active:   Hyprland.activeWorkspace !== null && workspace.id === Hyprland.activeWorkspace.id
    property bool occupied: workspace.clientCount > 0

    implicitWidth:  active ? 18 : 8
    implicitHeight: 8
    radius:         height / 2
    color:          active   ? "#e8a84c" :
                    occupied ? "#9a9590" :
                               "#4a4845"

    Behavior on implicitWidth { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Behavior on color          { ColorAnimation  { duration: 120 } }

    TapHandler { onTapped: Hyprland.dispatch("workspace " + workspace.id) }
}
