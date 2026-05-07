import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

import "../components/"

Item {
    id: root

    property bool popupOpen: false

    implicitWidth: batteryRow.implicitWidth + 25
    implicitHeight: 32

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
            return batteryIcons.zero

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

        if (state === UPowerDeviceState.Charging) {
            const hours = Math.floor(battery.timeToFull / 3600)
            const mins = Math.floor((battery.timeToFull % 3600) / 60)

            return `Full in ${hours} hr ${mins} min`
        }

        if (state === UPowerDeviceState.Discharging) {
            const hours = Math.floor(battery.timeToEmpty / 3600)
            const mins = Math.floor((battery.timeToEmpty % 3600) / 60)

            return `Empty in ${hours} hr ${mins} min`
        }

        if (state === UPowerDeviceState.FullyCharged)
            return "Fully Charged"
    }

    Pill {
        anchors.fill: root

        RowLayout {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 3

            // Charging Icon
            TextField {
                visible: root.battery.state === UPowerDeviceState.Charging
                text: "󱐋"
            }

            // Battery Icon
            TextField {
                text: root.getBatteryIcon()
            }

            // Battery Percentage
            TextField {
                text: root.battery ? (root.battery.percentage * 100) + "%" : "--%"
            }

        }
        // Hover charging state/remainging time
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: root.popupOpen = true
            onExited: root.popupOpen = false
        }
    }

    // Battery State Popup
    PopupWindow {
        anchor.item: root

        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height

        implicitWidth: stateText.implicitWidth + 20
        implicitHeight: root.height * 0.85
        color: "transparent"
        visible: root.popupOpen

        Pill {
            anchors.fill: parent

            TextField {
                id: stateText
                anchors.centerIn: parent
                text: root.getBatteryState()
            }
        }
    }
}
