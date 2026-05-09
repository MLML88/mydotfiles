import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

import "../components/"
import "../services/"
import "../themes/"

Item {
    id: root

    Loader {
        id: volumePopupLoader
        active: false
        sourceComponent: PanelWindow {
            anchors.right: true
            anchors.bottom: true

            margins.bottom: (screen.height / 2 - implicitHeight / 2)

            implicitWidth: volumeSlider.implicitWidth * 1.5
            implicitHeight: volumeSlider.implicitHeight * 1.1

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Pill {
                anchors.fill: parent
                color: TokyoNight.background

                ClippingRectangle {
                    id: volumeSlider
                    anchors.centerIn: parent
                    radius: 99
                    color: "grey"

                    implicitWidth: Math.max(volumeText.implicitWidth, 35)
                    implicitHeight: 200

                    Rectangle {
                        anchors.bottom: parent.bottom
                        color: TokyoNight.activeCol

                        implicitWidth: volumeSlider.implicitWidth
                        implicitHeight: Volume.vol * volumeSlider.implicitHeight
                    }

                    TextField {
                        id: volumeText
                        anchors.centerIn: parent
                        color: TokyoNight.background
                        text: Volume.muted ? Volume.volumeIcons.muted : Volume.getVolumePercent()
                    }
                }
            }
        }
    }

    Timer {
        id: volumePopupHideTimer
        interval: 1000
        repeat: false

        onTriggered: {
            volumePopupLoader.active = false
        }
    }

    Connections {
        target: Volume

        function onVolChanged() {
            volumePopupLoader.active = true
            volumePopupHideTimer.restart()
        }

        function onMutedChanged() {
            volumePopupLoader.active = true
            volumePopupHideTimer.restart()
        }
    }
}
