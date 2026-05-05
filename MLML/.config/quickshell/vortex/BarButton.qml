import QtQuick

Rectangle {
    property string text: ""
    signal clicked

    implicitWidth:  Math.max(28, label.implicitWidth + 16)
    implicitHeight: 24
    radius:         4
    color:          hov.containsMouse ? "#1e2128" : "transparent"

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        text:             parent.text
        color:            "#e8e3d8"
        font.pixelSize:   13
    }

    HoverHandler { id: hov }
    TapHandler   { onTapped: parent.clicked() }
}
