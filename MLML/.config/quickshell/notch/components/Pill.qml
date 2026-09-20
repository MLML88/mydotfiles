import QtQuick
import "../services"
import "../config"
import "../modules/clock"

Rectangle {
    id: root

    color: Theme.pillBackground
    radius: Metrics.radiusFor(height)

    implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth + Metrics.pillPaddingH * 2 : Metrics.idleHeight * 2
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + Metrics.pillPaddingV * 2 : Metrics.idleHeight
    width: implicitWidth
    height: implicitHeight

    Behavior on width { SpringAnimation { spring: Metrics.pillSpring; damping: Metrics.pillDamping } }
    Behavior on height { SpringAnimation { spring: Metrics.pillSpring; damping: Metrics.pillDamping } }
    Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    // Content stays hidden until the shape settles, then fades/scales in.
    property bool revealed: true
    property bool ready: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: if (NotchState.current === NotchState.idle) NotchState.expand(NotchState.clock)
        onClicked: NotchState.toggle(NotchState.clock)
    }

    Item {
        id: contentHost
        anchors.centerIn: parent
        opacity: root.revealed ? 1 : 0
        scale: root.revealed ? 1 : 0.92

        Behavior on opacity { NumberAnimation { duration: Metrics.contentFadeDuration; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Metrics.contentFadeDuration; easing.type: Easing.OutCubic } }

        Loader {
            id: contentLoader
            anchors.centerIn: parent
            sourceComponent: NotchState.current === NotchState.idle ? idleComponent : expandedComponent
        }
    }

    Component { id: idleComponent; ClockIdle {} }
    Component { id: expandedComponent; ClockExpanded {} }

    Timer {
        id: revealTimer
        interval: Metrics.shapeSettleDelay
        onTriggered: root.revealed = true
    }

    Connections {
        target: NotchState
        function onCurrentChanged() {
            if (!root.ready) return;
            root.revealed = false;
            revealTimer.restart();
        }
    }

    Component.onCompleted: root.ready = true
}
