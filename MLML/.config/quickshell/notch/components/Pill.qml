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

    readonly property real topGap: Config.floating ? Metrics.topGapFloating : 0
    // Top corners drive the flare and use a large, capped radius. Bottom corners use their
    // own smaller cap so the expanded view isn't overly round at the bottom just because
    // the top flare is generous. Both are fully round at idle size regardless.
    readonly property real cornerRadius: Metrics.cornerRadiusFor(notchWidth, notchBodyHeight)
    readonly property real bottomRadius: Metrics.bottomCornerRadiusFor(notchWidth, notchBodyHeight)
    // radii are intentionally not animated on their own: they must track width/height's live
    // value every frame of the resize, or they drift out of sync with the shape.

    // FLUSH mode's top corners are concave: the shape is at its FULL flare width right at
    // y=0 (flush with the screen edge) and narrows inward to the notch's own stable width
    // by y=cornerRadius. That flare extends past the notch's own width, so the shape (and
    // this item) needs extra width on each side to fit it without clipping. FLOATING mode
    // needs no extra width — its top corners round inward in the normal (convex) way.
    readonly property real flareRadius: Config.floating ? 0 : cornerRadius
    readonly property real shapeWidth: notchWidth + flareRadius * 2

    readonly property real kappa: 0.5522847498
    readonly property real r: cornerRadius
    readonly property real rk: cornerRadius * kappa
    readonly property real r1k: cornerRadius * (1 - kappa)
    readonly property real br: bottomRadius
    readonly property real brk: bottomRadius * kappa
    readonly property real br1k: bottomRadius * (1 - kappa)

    // Where the flat top segment starts/ends, and where the top corner curves hand off to
    // the straight vertical sides — these differ structurally between the two modes (see
    // above), not just by swapping a direction flag.
    readonly property real topFlatLeft: Config.floating ? r : 0
    readonly property real topFlatRight: Config.floating ? shapeWidth - r : shapeWidth
    readonly property real sideLeftX: flareRadius
    readonly property real sideRightX: shapeWidth - flareRadius

    // Top-right curve: FLOATING goes from (shapeWidth-r,0) to (shapeWidth,r) bulging out to
    // the full width (standard convex, center inside at (shapeWidth-r,r)). FLUSH goes from
    // (shapeWidth,0) to (shapeWidth-r,r), starting at the full flare width and narrowing
    // in (concave, center at (shapeWidth,r)) — verified against the rendered, pixel-measured
    // result, not just derived on paper; the naive "center at the outer corner" derivation
    // that seemed obvious turned out backwards in practice.
    readonly property real trEndX: sideRightX
    readonly property real trC1X: Config.floating ? shapeWidth - r1k : shapeWidth - rk
    readonly property real trC2X: trEndX
    readonly property real trC2Y: r1k
    // Top-left mirrors top-right: control1 sits near the curve's start (sideLeftX, r) with
    // the same formula in both modes; control2 sits near its end (topFlatLeft, 0) and is
    // where the two modes actually differ.
    readonly property real tlC1X: sideLeftX
    readonly property real tlC1Y: r1k
    readonly property real tlC2X: Config.floating ? r1k : rk
    readonly property real tlC2Y: r1k

    implicitWidth: shapeWidth
    implicitHeight: topGap + notchBodyHeight
    width: implicitWidth
    height: implicitHeight
    clip: true

    Shape {
        y: root.topGap
        width: root.shapeWidth
        height: root.notchBodyHeight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.pillBackground
            strokeWidth: -1

            startX: root.topFlatLeft
            startY: 0
            PathLine { x: root.topFlatRight; y: 0 }
            PathCubic {
                control1X: root.trC1X; control1Y: 0
                control2X: root.trC2X; control2Y: root.trC2Y
                x: root.trEndX; y: root.r
            }
            PathLine { x: root.sideRightX; y: root.notchBodyHeight - root.br }
            PathCubic {
                control1X: root.sideRightX; control1Y: root.notchBodyHeight - root.br1k
                control2X: root.sideRightX - root.br1k; control2Y: root.notchBodyHeight
                x: root.sideRightX - root.br; y: root.notchBodyHeight
            }
            PathLine { x: root.sideLeftX + root.br; y: root.notchBodyHeight }
            PathCubic {
                control1X: root.sideLeftX + root.br1k; control1Y: root.notchBodyHeight
                control2X: root.sideLeftX; control2Y: root.notchBodyHeight - root.br1k
                x: root.sideLeftX; y: root.notchBodyHeight - root.br
            }
            PathLine { x: root.sideLeftX; y: root.r }
            PathCubic {
                control1X: root.tlC1X; control1Y: root.tlC1Y
                control2X: root.tlC2X; control2Y: 0
                x: root.topFlatLeft; y: 0
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

    // Content is positioned within the notch's own stable body (excluding the flare
    // margins), not the wider shape bounds. Clipped so it can never render past the
    // notch's current bounds mid-morph.
    Item {
        id: notchBounds
        x: root.flareRadius
        y: root.topGap
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
