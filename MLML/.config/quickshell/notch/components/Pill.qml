import QtQuick
import QtQuick.Shapes
import "../services"
import "../config"
import "../modules/clock"

Item {
    id: root

    // In FLUSH mode the top corners curve inward (concave), like a real notch flowing out
    // of the screen bezel; in FLOATING mode all four corners round outward normally.
    readonly property real cornerRadius: Metrics.cornerRadiusFor(width, height)
    readonly property int topDirection: Config.floating ? PathArc.Counterclockwise : PathArc.Clockwise

    clip: true

    implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth + Metrics.pillPaddingH * 2 : Metrics.idleHeight * 2
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + Metrics.pillPaddingV * 2 : Metrics.idleHeight
    width: implicitWidth
    height: implicitHeight

    Behavior on width { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    Behavior on height { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    // cornerRadius is intentionally not animated on its own: it must track width/height's
    // live value every frame of the resize, or it drifts out of sync with the shape.

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.pillBackground
            strokeWidth: -1

            startX: root.cornerRadius
            startY: 0
            PathLine { x: root.width - root.cornerRadius; y: 0 }
            PathArc {
                x: root.width; y: root.cornerRadius
                radiusX: root.cornerRadius; radiusY: root.cornerRadius
                direction: root.topDirection
            }
            PathLine { x: root.width; y: root.height - root.cornerRadius }
            PathArc {
                x: root.width - root.cornerRadius; y: root.height
                radiusX: root.cornerRadius; radiusY: root.cornerRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: root.cornerRadius; y: root.height }
            PathArc {
                x: 0; y: root.height - root.cornerRadius
                radiusX: root.cornerRadius; radiusY: root.cornerRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: 0; y: root.cornerRadius }
            PathArc {
                x: root.cornerRadius; y: 0
                radiusX: root.cornerRadius; radiusY: root.cornerRadius
                direction: root.topDirection
            }
        }
    }

    // Click to expand; moving the mouse off the pill collapses it again. Esc is kept as a
    // keyboard fallback while expanded.
    focus: NotchState.current !== NotchState.idle
    Keys.onEscapePressed: NotchState.collapse()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: NotchState.toggle(NotchState.clock)
        onExited: if (NotchState.current !== NotchState.idle) NotchState.collapse()
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
