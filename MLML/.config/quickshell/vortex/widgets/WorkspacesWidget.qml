import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "../components/"
import "../themes/"

Item {
    id: root

    implicitWidth: workspacesRow.implicitWidth + 25
    implicitHeight: 32

    required property string monitorName
    property var workspaceSet:
        monitorName === "HDMI-A-1" ? [1, 2, 3, 4, 5]
        : monitorName === "eDP-1" ? [6, 7, 8, 9, 10]
        : monitorName === "eDP-2" ? [6, 7, 8, 9, 10]
        : [1, 2, 3, 4, 5]

    Pill {
        anchors.fill: root

        RowLayout {
            id: workspacesRow
            spacing: 5
            anchors.centerIn: parent

            Repeater {
                model: root.workspaceSet

                Pill {
                    id: ws
                    required property int modelData

                    property var workspace: Hyprland.workspaces.values.find(w => w.id === modelData)
                    property bool active: Hyprland.focusedWorkspace?.id === modelData

                    implicitWidth: active ? 50 : 30
                    implicitHeight: root.implicitHeight * 0.65

                    color: active ? TokyoNight.activeCol : TokyoNight.textCol

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.InOutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                            easing.type: Easing.InOutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ws.modelData
                        color: TokyoNight.background
                        font {
                            pixelSize: TokyoNight.pixelSize
                            family: TokyoNight.family
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (ws.workspace)
                                ws.workspace.activate()
                            else
                                Hyprland.dispatch("workspace " + ws.modelData)
                        }
                    }
                }
            }
        }
    }
}
