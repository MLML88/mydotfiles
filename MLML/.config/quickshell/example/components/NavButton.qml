import QtQuick
import QtQuick.Layouts
import "../themes"

// Small square icon button, e.g. the «‹ ›» month/year steppers in
// Calendar.qml. Generic enough to reuse anywhere a widget needs the same
// "circle-ish hover target with a glyph in it" affordance.
Rectangle {
    id: root
    signal activated()

    property string label

    implicitWidth: 32
    implicitHeight: 32
    // Without these, a RowLayout is free to shrink this below implicitWidth
    // to make room for a sibling that wants more space (e.g. Calendar's
    // month/year label) — which is exactly what let that label visually
    // cover these buttons before.
    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight

    radius: 6
    color: hoverHandler.hovered ? Theme.surface0 : "transparent"

    Text {
        anchors.centerIn: parent
        text: root.label
        color: Theme.subtext0
        font.pixelSize: 17
    }

    HoverHandler { id: hoverHandler }
    TapHandler { onTapped: root.activated() }
}
