pragma Singleton
import QtQuick

QtObject {
    // FLOATING keeps a gap between the pill and the screen edge; FLUSH sits directly on it,
    // reading as a shape hanging down from the bezel.
    property bool floating: false
}
