import QtQuick
import QtQuick.Shapes
import "../services"
import "../config"
import "../modules/clock"

Item {
    id: root

    required property NotchState notchState

    // In FLUSH mode the top corners curve inward (concave), like a real notch flowing out
    // of the screen bezel, using a larger radius than the bottom so the curve reads as most
    // of the top edge instead of a small nub in each corner. In FLOATING mode all four
    // corners round outward normally with the same (smaller) radius.
    readonly property real bottomRadius: Metrics.cornerRadiusFor(width, height)
    readonly property real topRadius: Config.floating ? bottomRadius : Metrics.earRadiusFor(width, height)
    readonly property int topDirection: Config.floating ? PathArc.Counterclockwise : PathArc.Clockwise

    clip: true

    implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth + Metrics.pillPaddingH * 2 : Metrics.idleHeight * 2
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + Metrics.pillPaddingV * 2 : Metrics.idleHeight
    width: implicitWidth
    height: implicitHeight

    Behavior on width { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    Behavior on height { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    // The radii are intentionally not animated on their own: they must track width/height's
    // live value every frame of the resize, or they drift out of sync with the shape.

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.pillBackground
            strokeWidth: -1

            startX: root.topRadius
            startY: 0
            PathLine { x: root.width - root.topRadius; y: 0 }
            PathArc {
                x: root.width; y: root.topRadius
                radiusX: root.topRadius; radiusY: root.topRadius
                direction: root.topDirection
            }
            PathLine { x: root.width; y: root.height - root.bottomRadius }
            PathArc {
                x: root.width - root.bottomRadius; y: root.height
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: root.bottomRadius; y: root.height }
            PathArc {
                x: 0; y: root.height - root.bottomRadius
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: 0; y: root.topRadius }
            PathArc {
                x: root.topRadius; y: 0
                radiusX: root.topRadius; radiusY: root.topRadius
                direction: root.topDirection
            }
        }
    }

    // Click to expand; moving the mouse off the pill collapses it again. Esc is kept as a
    // keyboard fallback while expanded.
    focus: notchState.current !== notchState.idle
    Keys.onEscapePressed: notchState.collapse()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.notchState.toggle(root.notchState.clock)
        onExited: if (root.notchState.current !== root.notchState.idle) root.notchState.collapse()
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
            sourceComponent: root.notchState.current === root.notchState.idle ? idleComponent : expandedComponent
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
        target: root.notchState
        function onCurrentChanged() {
            revealAnimation.stop();
            contentHost.opacity = 0;
            contentHost.scale = 0.92;
            revealTimer.restart();
        }
    }
}
