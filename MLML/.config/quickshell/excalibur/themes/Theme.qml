pragma Singleton
import QtQuick

// Color tokens, named after the Catppuccin Mocha palette every widget was
// already hardcoding. Centralizing them here means restyling — or swapping
// palettes entirely later — is a one-file change instead of a grep-and-edit
// across every widget.
QtObject {
    readonly property color base: "#1e1e2e"       // pill / panel background
    readonly property color crust: "#11111b"      // recessed surfaces (search box)
    readonly property color surface0: "#313244"   // hover / selection background
    readonly property color surface2: "#585b70"   // stronger selection (selected calendar day)
    readonly property color overlay1: "#7f849c"   // muted labels (weekday headers)
    readonly property color subtext0: "#a6adc8"   // secondary text (nav arrows)
    readonly property color text: "#cdd6f4"       // primary text
    readonly property color blue: "#89b4fa"       // accent (today, active states)
    readonly property color red: "#f38ba8"        // errors (failed wifi connect, etc.)
}
