pragma Singleton
import QtQuick

QtObject {
    // FLOATING keeps a gap between the pill and the screen edge; FLUSH sits directly on it,
    // flush mode also squares off the top corners so the pill reads as hanging from the bezel.
    property bool floating: false
}
