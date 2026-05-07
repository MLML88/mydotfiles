import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "../components/"
import "../themes/"

Item {
    id: root

    implicitWidth: 200
    implicitHeight: 32

    Pill {
        anchors.fill: root

        RowLayout {
            spacing: 5
            anchors.centerIn: parent

            Repeater {
                model: 5

                Pill {
                    id: ws
                    required property int index

                    property var workspace: Hyprland.workspaces.values.find(w => w.id === index + 1)
                    property bool active: Hyprland.focusedWorkspace?.id === index + 1

                    implicitWidth: active ? 40 : 30
                    implicitHeight: 20

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
                        text: ws.index + 1
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
                            Hyprland.dispatch("workspace " + (ws.index + 1))
                        }
                    }
                }
            }
        }
    }
}
