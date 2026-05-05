import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

RowLayout {
    spacing: 4

    Repeater {
        model: SystemTray.items
        delegate: Item {
            required property var modelData
            implicitWidth:  20
            implicitHeight: 20

            Image {
                anchors.fill: parent
                source:       modelData.icon
                fillMode:     Image.PreserveAspectFit
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onTapped: (ev) => {
                    if (ev.button === Qt.LeftButton)
                        modelData.activate()
                    else
                        modelData.openMenu()
                }
            }
        }
    }
}
