pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var currentNetwork: wifi?.networks?.values.find(n => n.connected)
    property int signalStrength: currentNetwork?.signalStrength * 100 ?? 0

    property var networkIcons: [
        {limit: 100, icon: "󰤨"},
        {limit: 75, icon: "󰤥"},
        {limit: 50, icon: "󰤢"},
        {limit: 25, icon: "󰤟"},
        {limit: 0, icon: "󰤯"},
    ]

    function getNetworkIcon() {
        if (!currentNetwork)
            return networkIcons.find(n => n.limit === 0).icon

        for (const entry of networkIcons) {
            if (signalStrength >= entry.limit)
                return entry.icon
        }
    }
}
