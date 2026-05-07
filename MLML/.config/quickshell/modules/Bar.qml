import Quickshell // for Text
import QtQuick
import QtQuick.Layouts

import "../widgets/"

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

            implicitHeight: 40
            color: "transparent"

            // Left Bar
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

            }

            // Middle Bar
            RowLayout {
                anchors.centerIn: parent
                spacing: 5

                ClockWidget {
                    Layout.preferredHeight: bar.height * 0.85
                }
                WorkspacesWidget {
                    Layout.preferredHeight: bar.height * 0.85
                }
            }

            // Right Bar
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

           }
        }
    }
}
