import QtQuick
import QtQuick.Layouts
import "../themes"
import "../components"
import "../services"

ColumnLayout {
    id: root
    spacing: 8

    ControlToggle {
        Layout.fillWidth: true
        label: "Wi-Fi"
        status: SystemControl.wifiEnabled ? (SystemControl.wifiSSID || "Not connected") : "Off"
        checked: SystemControl.wifiEnabled
        onToggled: SystemControl.toggleWifi()
        onClicked: ControlCenterState.showWifiList()
    }

    ControlToggle {
        Layout.fillWidth: true
        label: "Bluetooth"
        status: SystemControl.bluetoothEnabled ? (SystemControl.bluetoothDevice || "Not connected") : "Off"
        checked: SystemControl.bluetoothEnabled
        onToggled: SystemControl.toggleBluetooth()
        onClicked: ControlCenterState.showBluetoothList()
    }

    ControlSlider {
        Layout.fillWidth: true
        label: "Volume"
        value: SystemControl.volumeMuted ? 0 : SystemControl.volume
        valueText: SystemControl.volumeMuted ? "Muted" : Math.round(SystemControl.volume * 100) + "%"
        onAdjusted: (v) => SystemControl.setVolume(v)
    }

    ControlSlider {
        Layout.fillWidth: true
        visible: SystemControl.brightnessAvailable
        label: "Brightness"
        value: SystemControl.brightness
        valueText: Math.round(SystemControl.brightness * 100) + "%"
        onAdjusted: (v) => SystemControl.setBrightness(v)
    }
}
