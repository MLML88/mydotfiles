import QtQuick
import QtQuick.Layouts

// Mpris may not be available - wrap in a Loader-style guard
RowLayout {
    spacing: 4
    visible: false   // hidden until we confirm Mpris works; remove this line if you have a media player

    Text {
        text:           "♫"
        color:          "#e8a84c"
        font.pixelSize: 11
    }

    Text {
        text:             ""
        color:            "#9a9590"
        font.pixelSize:   11
        elide:            Text.ElideRight
        maximumLineCount: 1
        Layout.maximumWidth: 180
    }
}
