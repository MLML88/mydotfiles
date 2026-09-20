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

    // Morph animation: a fixed-duration OutBack curve gives the shape change a controllable
    // overshoot, so content reveal can be timed to exactly when the shape settles (a physics
    // based SpringAnimation has no fixed settle time, which let content reveal before the
    // shape had actually finished growing).
    readonly property int morphDuration: 260
    readonly property real morphOvershoot: 1.4
    readonly property int contentFadeDuration: 140
    readonly property int contentRevealDelay: morphDuration + 20
}
