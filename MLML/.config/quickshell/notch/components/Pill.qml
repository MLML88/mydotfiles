import QtQuick
import QtQuick.Shapes
import "../services"
import "../config"
import "../modules/clock"

Item {
    id: root

    required property NotchState notchState

    readonly property real targetNotchWidth: contentLoader.item ? contentLoader.item.implicitWidth + Metrics.pillPaddingH * 2 : Metrics.idleHeight * 2
    readonly property real targetNotchBodyHeight: contentLoader.item ? contentLoader.item.implicitHeight + Metrics.pillPaddingV * 2 : Metrics.idleHeight

    property real notchWidth: targetNotchWidth
    property real notchBodyHeight: targetNotchBodyHeight
    Behavior on notchWidth { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }
    Behavior on notchBodyHeight { NumberAnimation { duration: Metrics.morphDuration; easing.type: Easing.OutBack; easing.overshoot: Metrics.morphOvershoot } }

    // The strip only makes sense flush against the screen edge. Floating mode falls back to
    // a plain flat top (fillet radius 0 degenerates the corner arcs below into sharp corners).
    readonly property bool useStrip: !Config.floating && Config.stripEnabled
    readonly property real stripHeight: useStrip ? Metrics.stripHeight : 0
    readonly property real filletRadius: useStrip ? Metrics.stripHeight : 0
    readonly property real bottomRadius: Metrics.cornerRadiusFor(notchWidth, notchBodyHeight)
    readonly property real topGap: Config.floating ? Metrics.topGapFloating : 0
    readonly property real notchTop: topGap + stripHeight
    readonly property real notchLeft: (width - notchWidth) / 2
    readonly property real notchRight: notchLeft + notchWidth
    // radii are intentionally not animated on their own: they must track width/height's live
    // value every frame of the resize, or they drift out of sync with the shape.

    implicitHeight: notchTop + notchBodyHeight
    height: implicitHeight

    Rectangle {
        visible: root.useStrip
        color: Theme.stripBackground
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.stripHeight
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.pillBackground
            strokeWidth: -1

            startX: root.notchLeft - root.filletRadius
            startY: root.notchTop
            PathLine { x: root.notchRight + root.filletRadius; y: root.notchTop }
            PathArc {
                x: root.notchRight; y: root.notchTop + root.filletRadius
                radiusX: root.filletRadius; radiusY: root.filletRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: root.notchRight; y: root.height - root.bottomRadius }
            PathArc {
                x: root.notchRight - root.bottomRadius; y: root.height
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: root.notchLeft + root.bottomRadius; y: root.height }
            PathArc {
                x: root.notchLeft; y: root.height - root.bottomRadius
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: root.notchLeft; y: root.notchTop + root.filletRadius }
            PathArc {
                x: root.notchLeft - root.filletRadius; y: root.notchTop
                radiusX: root.filletRadius; radiusY: root.filletRadius
                direction: PathArc.Clockwise
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

    // Content is positioned within the notch's own (animated) bounds, not the full strip
    // width. Clipped so it can never render past the notch's current bounds mid-morph.
    Item {
        id: notchBounds
        x: root.notchLeft
        y: root.notchTop
        width: root.notchWidth
        height: root.notchBodyHeight
        clip: true

        // Content is hidden by a direct property assignment (never a Behavior) so hiding is
        // always instant; only the reveal, once the shape has settled, is an explicit,
        // animated step. Toggling a Behavior's `enabled` in the same tick as the property it
        // guards does not reliably suppress the animation for that change, which is what let
        // content flash mid-resize before this.
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
