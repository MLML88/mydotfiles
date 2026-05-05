import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen:        modelData
            anchors {
                top:   true
                left:  true
                right: true
            }
            implicitHeight: 36
            color:          "transparent"
            exclusiveZone:  implicitHeight

            Rectangle {
                anchors.fill: parent
                color:        "#16181c"
                border.color: "#2a2d35"
                border.width: 1

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left:   parent.left
                        right:  parent.right
                    }
                    height:  1
                    color:   "#e8a84c"
                    opacity: 0.35
                }

                RowLayout {
                    anchors {
                        fill:        parent
                        leftMargin:  10
                        rightMargin: 10
                    }
                    spacing: 0

                    RowLayout {
                        spacing: 6

                        BarButton {
                            text:      ""
                            onClicked: Hyprland.dispatch("exec fuzzel")
                        }

                        Repeater {
                            model: Hyprland.workspaces
                            delegate: WorkspaceDot {
                                required property var modelData
                                workspace: modelData
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        Layout.alignment:    Qt.AlignHCenter
                        text:                Hyprland.focusedClient ? Hyprland.focusedClient.title : ""
                        color:               "#e8e3d8"
                        font.family:         "monospace"
                        font.pixelSize:      12
                        elide:               Text.ElideRight
                        maximumLineCount:    1
                        Layout.maximumWidth: 400
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignRight

                        MprisNowPlaying {}
                        SystemTrayArea {}
                        Clock {}
                    }
                }
            }
        }
    }
}
