import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "../components/"
import "../themes/"

Item {
    id: root

    GlobalShortcut {
        appid: "vortex"
        name: "applauncher"
        description: "Opens app launcher"

        onPressed: {
            appLauncherLoader.active = !appLauncherLoader.active
        }
    }

    Loader {
        id: appLauncherLoader
        active: false
        sourceComponent: PanelWindow {
            id: appLauncherMenu

            implicitWidth: 400
            implicitHeight: 450

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Pill {
                anchors.centerIn: parent

                implicitWidth: parent.width
                implicitHeight: parent.height

                radius: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20

                    spacing: 12

                    Pill {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        color: TokyoNight.textCol

                        Pill {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            implicitHeight: parent.height
                            implicitWidth: parent.width * 0.25
                            color: TokyoNight.activeCol

                            TextField {
                                anchors.centerIn: parent

                                color: TokyoNight.background
                                font.pixelSize: 15
                                text: "Search"
                            }

                            TextInput {
                                focus: true
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true
                        spacing: 10

                        model: DesktopEntries.applications.values

                        delegate: Rectangle {
                            required property var modelData

                            width: ListView.view.width
                            height: 38
                            radius: 15

                            color: mouse.containsMouse
                            ? TokyoNight.textCol
                            : TokyoNight.activeCol

                            TextField {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12

                                text: modelData.name
                                color: TokyoNight.background
                                font.pixelSize: 15
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }
    }
}
