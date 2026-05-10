import Quickshell // for Text
import QtQuick
import QtQuick.Layouts

import "../widgets/"
import "../themes/"

Scope {
    Variants {
        model: Quickshell.screens;

        PanelWindow {
            required property var modelData
            screen: modelData
            id: bar

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 15
                left: 15
                right: 15
            }

            implicitHeight: 35
            color: "transparent"

            // Left Bar
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: TokyoNight.pillSpacing

                IconWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
                ActiveWindowWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
            }

            // Middle Bar
            RowLayout {
                anchors.centerIn: parent
                spacing: TokyoNight.pillSpacing

                ClockWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
                WorkspacesWidget {
                    monitorName: screen.name
                    Layout.preferredHeight: bar.implicitHeight
                }
            }

            // Right Bar
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: TokyoNight.pillSpacing

                VolumeWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
                NetworkWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
                BatteryWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
                NotificationWidget {
                    Layout.preferredHeight: bar.implicitHeight
                }
           }
        }
    }
}
