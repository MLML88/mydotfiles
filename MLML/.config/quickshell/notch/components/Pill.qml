import QtQuick
import "../services"
import "../config"
import "../modules/clock"

Rectangle {
    id: root

    color: Theme.pillBackground
    radius: Metrics.radiusFor(height)
    // Clip so the content can never render past the pill's current bounds while it's
    // still mid-morph (otherwise a bigger view's text is visible before the shape catches up).
    clip: true

    implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth + Metrics.pillPaddingH * 2 : Metrics.idleHeight * 2
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + Metrics.pillPaddingV * 2 : Metrics.idleHeight
    width: implicitWidth
    height: implicitHeight

    Behavior on width { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    Behavior on height { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    // radius is intentionally not animated on its own: it must track height's live value on
    // every frame of the resize, or it drifts out of sync with the shape until height settles.

    // Squares off the top corners in FLUSH mode so the pill reads as hanging down from the
    // screen edge instead of floating as a full stadium shape.
    Rectangle {
        visible: !Config.floating
        color: parent.color
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: parent.radius
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: if (NotchState.current === NotchState.idle) NotchState.expand(NotchState.clock)
        onClicked: NotchState.toggle(NotchState.clock)
    }

    // Content is hidden by a direct property assignment (never a Behavior) so hiding is always
    // instant; only the reveal, once the shape has settled, is an explicit, animated step. Toggling
    // a Behavior's `enabled` in the same tick as the property it guards does not reliably suppress
    // the animation for that change, which is what let content flash mid-resize before this.
    Item {
        id: contentHost
        anchors.centerIn: parent
        opacity: 1
        scale: 1

        Loader {
            id: contentLoader
            anchors.centerIn: parent
            sourceComponent: NotchState.current === NotchState.idle ? idleComponent : expandedComponent
        }
    }

    Component { id: idleComponent; ClockIdle {} }
    Component { id: expandedComponent; ClockExpanded {} }

    ParallelAnimation {
        id: revealAnimation
        NumberAnimation { target: contentHost; property: "opacity"; to: 1; duration: Metrics.contentFadeDuration; easing.type: Easing.OutCubic }
        NumberAnimation { target: contentHost; property: "scale"; to: 1; duration: Metrics.contentFadeDuration; easing.type: Easing.OutCubic }
    }

    Timer {
        id: revealTimer
        interval: Metrics.contentRevealDelay
        onTriggered: revealAnimation.start()
    }

    Connections {
        target: NotchState
        function onCurrentChanged() {
            revealAnimation.stop();
            contentHost.opacity = 0;
            contentHost.scale = 0.92;
            revealTimer.restart();
        }
    }
}
