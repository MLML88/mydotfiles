pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property double vol: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    property var btDevice: Bluetooth.devices.values.find(d => d.connected)
    property bool isBluetooth: (sink?.name ?? "").includes("bluez")

    property var volumeIcons: ({
        muted: "",
        low: "",
        mid: "",
        high: "",
    })

    property var bluetoothIcons: [
        {limit: 1.0, icon: "󰁹"},
        {limit: 0.9, icon: "󰂂"},
        {limit: 0.8, icon: "󰂁"},
        {limit: 0.7, icon: "󰂀"},
        {limit: 0.6, icon: "󰁿"},
        {limit: 0.5, icon: "󰁾"},
        {limit: 0.4, icon: "󰁽"},
        {limit: 0.3, icon: "󰁼"},
        {limit: 0.2, icon: "󰁻"},
        {limit: 0.1, icon: "󰁺"},
        {limit: 0.0, icon: "󰂎"},
    ]

    PwObjectTracker {
        objects: [root.sink]
    }

    function getVolumeIcon() {
        if (vol === undefined || isNaN(vol) || muted)
        return volumeIcons.muted

        return (vol === 0.0) ? volumeIcons.low : (vol < 0.50) ? volumeIcons.mid : volumeIcons.high
    }

    function getVolumePercent() {
        if (vol === undefined || isNaN(vol))
        return "--%"

        return Math.round(vol * 100) + "%"
    }

    function getBluetoothIcon() {
        if (!btDevice)
            return bluetoothIcons.find(b => b.limit === 0).icon

        const percent = btDevice.battery

        for (const entry of bluetoothIcons) {
            if (percent >= entry.limit)
                return entry.icon
        }
    }
}
