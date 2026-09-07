import QtQuick
import QtQuick.Layouts
import "../themes"
import "../components"
import "../services"

ColumnLayout {
    id: root
    spacing: 8

    // ClockPill toggles this view's visibility (opacity > 0.01) as you
    // open/close it — start scanning for nearby devices while it's up,
    // stop as soon as it isn't, so it's not running in the background
    // the rest of the time.
    onVisibleChanged: {
        if (visible) SystemControl.startBluetoothScan();
        else SystemControl.stopBluetoothScan();
    }

    PickerHeader {
        Layout.fillWidth: true
        title: "Bluetooth"
        onBack: ControlCenterState.showMenu()
    }

    Text {
        visible: !SystemControl.bluetoothEnabled
        text: "Bluetooth is off"
        color: Theme.overlay1
        font.pixelSize: 12
    }

    Text {
        visible: SystemControl.bluetoothEnabled && SystemControl.bluetoothDevices.length === 0
        text: "Searching…"
        color: Theme.overlay1
        font.pixelSize: 12
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: SystemControl.bluetoothEnabled
        clip: true
        spacing: 4
        model: SystemControl.bluetoothDevices

        delegate: SelectableRow {
            width: ListView.view.width
            title: modelData.name
            subtitle: SystemControl.bluetoothConnectingMac === modelData.mac
                ? (modelData.paired ? "Connecting…" : "Pairing…")
                : (modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available"))
            active: modelData.connected
            onActivated: SystemControl.selectBluetoothDevice(modelData.mac, modelData.connected, modelData.paired)
        }
    }
}
