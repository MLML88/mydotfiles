pragma Singleton
import QtQuick

QtObject {
    // FLOATING keeps a gap between the pill and the screen edge; FLUSH sits directly on it,
    // reading as a shape hanging down from the bezel.
    property bool floating: false
    // Draws a slim full-width strip above the notch (FLUSH mode only) that the notch appears
    // to hang from, connected by concave fillets. This shell draws the strip itself rather
    // than depending on an external bar.
    property bool stripEnabled: true
}
