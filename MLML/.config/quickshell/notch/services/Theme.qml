pragma Singleton
import QtQuick

QtObject {
    // Pure black, opaque pill (see docs/PLAN.md's design reference section) — no
    // translucency/blur on the fill itself.
    readonly property color pillBackground: "#000000"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#9A9A9A"
    readonly property color accent: "#0A84FF"

    // Monospace so clock/stat digits are tabular by construction.
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSizeIdle: 13
    readonly property int fontSizeExpandedTime: 32
    readonly property int fontSizeExpandedDate: 15
}
