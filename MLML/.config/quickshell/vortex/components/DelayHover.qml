import QtQuick

MouseArea {
    id: root

    anchors.fill: parent
    hoverEnabled: true

    property int delay: 800
    required property var delayedHover

    Timer {
        id: timer
        interval: root.delay
        repeat: false

        onTriggered: {
            root.delayedHover.visible = true
        }
    }

    onEntered: {
        delayedHover.visible = false
        timer.restart()
    }

    onExited: {
        timer.stop()
        delayedHover.visible = false
    }
}
