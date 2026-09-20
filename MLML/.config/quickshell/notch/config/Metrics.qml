pragma Singleton
import QtQuick

QtObject {
    // Spacing scale — feature files pull from here instead of hardcoding pixel values.
    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int space3: 12
    readonly property int space4: 16
    readonly property int space5: 24

    // Pill geometry. The pill is always fully rounded (radius = height / 2).
    readonly property int idleHeight: 32
    readonly property int pillPaddingH: 16
    readonly property int pillPaddingV: 6
    readonly property int topGapFloating: 8
    readonly property int topMargin: Config.floating ? topGapFloating : 0

    function radiusFor(height) {
        return height / 2;
    }

    // Morph animation: a light SpringAnimation gives the shape change its overshoot.
    readonly property real pillSpring: 3.0
    readonly property real pillDamping: 0.4
    // Content waits for the shape to settle before fading/scaling in.
    readonly property int shapeSettleDelay: 180
    readonly property int contentFadeDuration: 140
}
