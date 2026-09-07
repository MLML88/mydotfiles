import QtQuick
import QtQuick.Layouts
import "../themes"
import "../components"
import "../services"

GridLayout {
    id: root
    columns: 2
    columnSpacing: 12
    rowSpacing: 12

    StatCard {
        Layout.fillWidth: true
        label: "CPU"
        value: SystemStats.cpuUsage.toFixed(0) + "%"
        percent: SystemStats.cpuUsage / 100
    }

    StatCard {
        Layout.fillWidth: true
        label: "GPU"
        value: SystemStats.gpuUsage.toFixed(0) + "%"
        percent: SystemStats.gpuUsage / 100
    }

    StatCard {
        Layout.fillWidth: true
        label: "CPU Temp"
        value: SystemStats.cpuTemp.toFixed(0) + "°C"
    }

    StatCard {
        Layout.fillWidth: true
        label: "GPU Temp"
        value: SystemStats.gpuTemp.toFixed(0) + "°C"
    }

    StatCard {
        Layout.fillWidth: true
        label: "Memory"
        value: SystemStats.memUsedGB.toFixed(1) + " / " + SystemStats.memTotalGB.toFixed(1) + " GB"
        percent: SystemStats.memUsage / 100
    }

    StatCard {
        Layout.fillWidth: true
        label: "Storage"
        value: SystemStats.diskUsedGB.toFixed(0) + " / " + SystemStats.diskTotalGB.toFixed(0) + " GB"
        percent: SystemStats.diskUsage / 100
    }

    StatCard {
        Layout.columnSpan: 2
        Layout.fillWidth: true
        label: "Battery"
        value: SystemStats.batteryPercent + "%" + (SystemStats.batteryCharging ? " (Charging)" : "")
        percent: SystemStats.batteryPercent / 100
    }
}
