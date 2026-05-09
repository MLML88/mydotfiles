pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    property var battery: UPower.displayDevice
    property var batteryIcons: [
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

    function getBatteryIcon() {
        if (!battery)
            return batteryIcons.find(b => b.limit === 0).icon

        const percent = battery.percentage

        for (const entry of batteryIcons) {
            if (percent >= entry.limit)
                return entry.icon
        }
    }

    function getBatteryState() {
        if (!battery)
            return "Battery Error"

        const state = battery.state
        var hours = 0
        var mins = 0

        switch (state) {
            case UPowerDeviceState.Charging:
                hours = Math.floor(battery.timeToFull / 3600)
                mins = Math.floor((battery.timeToFull % 3600) / 60)

                return `Full in ${hours} hr ${mins} min`

            case UPowerDeviceState.Discharging:
                hours = Math.floor(battery.timeToEmpty / 3600)
                mins = Math.floor((battery.timeToEmpty % 3600) / 60)

                return `Empty in ${hours} hr ${mins} min`

            case UPowerDeviceState.FullyCharged:
                return "Fully Charged"

            default:
                return "Unknown State"
        }
    }
}
