import QtQuick
import QtQuick.Layouts
import "../themes"
import "../components"
import "../services"

ColumnLayout {
    id: root
    spacing: 8

    PickerHeader {
        Layout.fillWidth: true
        title: "Wi-Fi"
        onBack: {
            SystemControl.cancelWifiPassword();
            ControlCenterState.showMenu();
        }
    }

    Text {
        visible: !SystemControl.wifiEnabled
        text: "Wi-Fi is off"
        color: Theme.overlay1
        font.pixelSize: 12
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: SystemControl.wifiEnabled
        clip: true
        spacing: 4
        model: SystemControl.wifiNetworks

        // Each row and its (usually collapsed) password field live in one
        // Column so the row's tap can grow the delegate in place — tapping
        // it again collapses the field right back (see selectWifiNetwork).
        delegate: Column {
            width: ListView.view.width
            spacing: 4

            SelectableRow {
                width: parent.width
                title: modelData.ssid
                subtitle: SystemControl.wifiConnectingSsid === modelData.ssid
                    ? (modelData.active ? "Disconnecting…" : "Connecting…")
                    : (modelData.active ? "Connected" : (modelData.secured ? "Secured" : "Open"))
                active: modelData.active || SystemControl.wifiPasswordSsid === modelData.ssid
                onActivated: SystemControl.selectWifiNetwork(modelData.ssid, modelData.active, modelData.secured)
            }

            Rectangle {
                id: passwordBox
                width: parent.width
                implicitHeight: 60
                visible: SystemControl.wifiPasswordSsid === modelData.ssid
                color: Theme.crust
                radius: 8

                onVisibleChanged: if (visible) passwordField.forceActiveFocus()

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 26
                        radius: 6
                        color: Theme.base

                        TextInput {
                            id: passwordField
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: Theme.text
                            font.pixelSize: 12
                            clip: true

                            Text {
                                text: "Password"
                                color: Theme.overlay1
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                                visible: passwordField.text.length === 0
                            }

                            Keys.onReturnPressed: { SystemControl.submitWifiPassword(text); text = ""; }
                            Keys.onEnterPressed: { SystemControl.submitWifiPassword(text); text = ""; }
                            Keys.onEscapePressed: { SystemControl.cancelWifiPassword(); text = ""; }
                        }
                    }

                    Text {
                        visible: SystemControl.wifiError !== ""
                        text: SystemControl.wifiError
                        color: Theme.red
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
