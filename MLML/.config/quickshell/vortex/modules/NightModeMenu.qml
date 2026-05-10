import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    property bool shown: false
    property int selected: 1

    visible: shown
    color: "transparent"

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitWidth: 360
    implicitHeight: 130

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: root.shown
        onCleared: root.shown = false
    }

    IpcHandler {
        target: "nightmenu"

        function toggle() {
            root.shown = !root.shown

            if (root.shown)
            menu.forceActiveFocus()
        }
    }

    function open() {
        shown = true
        menu.forceActiveFocus()
    }

    function close() {
        shown = false
    }

    function applyTemp(temp) {
        Hyprland.dispatch("exec pkill hyprsunset")

        restartTimer.temp = temp
        restartTimer.restart()

        close()
    }

    Timer {
        id: restartTimer
        
        property int temp: 4500

        interval: 1000
        repeat: false

        onTriggered: {
            Hyprland.dispatch(
                "exec hyprsunset -t " + temp
            )
        }
    }

    function currentTemp() {
        return temps.get(selected).value
    }

    ListModel {
        id: temps

        ListElement { label: "Subtle"; value: 5000 }
        ListElement { label: "Windows-like"; value: 4500 }
        ListElement { label: "Evening"; value: 4000 }
        ListElement { label: "Late night"; value: 3500 }
    }

    Rectangle {
        id: menu
        implicitWidth: 360
        implicitHeight: 110

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12

        radius: 24
        color: "#1a1b26"
        border.color: "#7aa2f7"
        border.width: 2
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.close()
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                root.selected = Math.max(0, root.selected - 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                root.selected = Math.min(temps.count - 1, root.selected + 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                root.applyTemp(root.currentTemp())
                event.accepted = true
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: temps

                Rectangle {
                    width: 78
                    height: 70
                    radius: 16

                    color: index === root.selected ? "#7aa2f7" : "#24283b"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: label
                            color: index === root.selected ? "#1a1b26" : "#c0caf5"
                            font.pixelSize: 12
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: value + "K"
                            color: index === root.selected ? "#1a1b26" : "#a9b1d6"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selected = index
                            root.applyTemp(value)
                        }
                    }
                }
            }
        }
    }
}
