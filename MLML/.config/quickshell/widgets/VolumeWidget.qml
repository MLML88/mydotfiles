import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "../components/"

Item {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property double vol: sink.audio.volume
    property bool muted: sink.audio.muted
    property var volumeIcons: ({
        muted: "",
        low: "",
        mid: "",
        high: "",
    })

    PwObjectTracker {
        objects: [root.sink]
    }

    implicitWidth: volumeRow.implicitWidth + 25
    implicitHeight: 32

    function getVolumeIcon() {
        if (root.vol === undefined || isNaN(root.vol) || root.muted)
            return volumeIcons.muted

        return (root.vol === 0.0) ? volumeIcons.low : (root.vol < 0.50) ? volumeIcons.mid : volumeIcons.high
    }

    function getVolumePercent() {
        if (root.vol === undefined || isNaN(root.vol))
            return "--%"

        return Math.round(vol * 100) + "%"
    }

    Pill {
        anchors.fill: root

        RowLayout {
            id: volumeRow
            anchors.centerIn: parent
            spacing: 5

            // Volume Icon
            TextField {
                text: root.getVolumeIcon()
            }

            // Volume Percentage
            TextField {
                visible: !root.sink.audio.muted
                text: root.getVolumePercent()
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: Quickshell.execDetached(["pavucontrol"])

            onWheel: event => {
                if (!root.sink)
                    return

                if (event.angleDelta.y > 0)
                    root.sink.audio.volume = Math.min(1.0, root.sink.audio.volume + 0.02)
                else
                    root.sink.audio.volume = Math.max(0.0, root.sink.audio.volume - 0.02)
            }
        }
    }
}
