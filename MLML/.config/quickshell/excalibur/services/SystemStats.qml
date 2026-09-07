pragma Singleton
import Quickshell.Io
import QtQuick

// Polls /proc and /sys periodically for CPU/GPU/memory stats. A singleton so
// the polling happens once regardless of how many Bar instances (monitors)
// are showing the dashboard.
QtObject {
    id: stats

    property real cpuUsage: 0    // 0-100
    property real gpuUsage: 0    // 0-100
    property real memUsedGB: 0
    property real memTotalGB: 0
    property real memUsage: 0    // 0-100
    property real diskUsedGB: 0
    property real diskTotalGB: 0
    property real diskUsage: 0   // 0-100
    property real cpuTemp: 0     // °C
    property real gpuTemp: 0     // °C
    property int batteryPercent: 0     // 0-100
    property bool batteryCharging: false

    property real _prevCpuTotal: -1
    property real _prevCpuIdle: -1

    // Resolved once at startup by _sensorResolver below — hwmon device
    // numbering (hwmon0, hwmon1, ...) and battery naming are enumeration-
    // order/hardware dependent, so we can't hardcode these paths.
    property string cpuTempPath: "/dev/null"
    property string gpuTempPath: "/dev/null"
    property string gpuBusyPath: "/dev/null"
    property string batteryCapacityPath: "/dev/null"
    property string batteryStatusPath: "/dev/null"

    function _parseCpuLine(t) {
        const line = t.split("\n")[0]; // "cpu  user nice system idle iowait irq softirq ..."
        const parts = line.trim().split(/\s+/).slice(1).map(Number);
        const idle = parts[3] + (parts[4] || 0);
        const total = parts.reduce((a, b) => a + b, 0);
        return [idle, total];
    }

    property FileView cpuStatFile: FileView {
        path: "/proc/stat"
        onLoaded: {
            const [idle, total] = stats._parseCpuLine(text());
            if (stats._prevCpuTotal >= 0) {
                const totalDelta = total - stats._prevCpuTotal;
                const idleDelta = idle - stats._prevCpuIdle;
                if (totalDelta > 0) stats.cpuUsage = (1 - idleDelta / totalDelta) * 100;
            }
            stats._prevCpuTotal = total;
            stats._prevCpuIdle = idle;
        }
    }

    property FileView memInfoFile: FileView {
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const totalKb = Number(t.match(/MemTotal:\s+(\d+)/)[1]);
            const availKb = Number(t.match(/MemAvailable:\s+(\d+)/)[1]);
            stats.memTotalGB = totalKb / 1048576;
            stats.memUsedGB = (totalKb - availKb) / 1048576;
            stats.memUsage = ((totalKb - availKb) / totalKb) * 100;
        }
    }

    property FileView cpuTempFile: FileView {
        path: stats.cpuTempPath
        onLoaded: stats.cpuTemp = Number(text()) / 1000
    }

    property FileView gpuTempFile: FileView {
        path: stats.gpuTempPath
        onLoaded: stats.gpuTemp = Number(text()) / 1000
    }

    property FileView gpuBusyFile: FileView {
        path: stats.gpuBusyPath
        onLoaded: stats.gpuUsage = Number(text())
    }

    property FileView batteryCapacityFile: FileView {
        path: stats.batteryCapacityPath
        onLoaded: stats.batteryPercent = Number(text())
    }

    property FileView batteryStatusFile: FileView {
        path: stats.batteryStatusPath
        onLoaded: stats.batteryCharging = text().trim() === "Charging"
    }

    // Finds the k10temp (CPU) and amdgpu (GPU) hwmon entries by name,
    // whichever /sys/class/drm/card* actually exposes gpu_busy_percent
    // (only the driven GPU does — on this hybrid laptop that's the AMD
    // iGPU, since the NVIDIA dGPU has no driver loaded), and the first
    // battery under /sys/class/power_supply.
    property Process _sensorResolver: Process {
        command: ["bash", "-c", 'for d in /sys/class/hwmon/hwmon*; do n=$(cat "$d/name" 2>/dev/null); [ "$n" = k10temp ] && echo "CPU_TEMP=$d/temp1_input"; [ "$n" = amdgpu ] && echo "GPU_TEMP=$d/temp1_input"; done; for c in /sys/class/drm/card*; do [ -f "$c/device/gpu_busy_percent" ] && echo "GPU_BUSY=$c/device/gpu_busy_percent"; done; for b in /sys/class/power_supply/BAT*; do [ -f "$b/capacity" ] && echo "BAT_CAPACITY=$b/capacity" && echo "BAT_STATUS=$b/status" && break; done']
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const [key, value] = line.split("=");
                    if (key === "CPU_TEMP") stats.cpuTempPath = value;
                    else if (key === "GPU_TEMP") stats.gpuTempPath = value;
                    else if (key === "GPU_BUSY") stats.gpuBusyPath = value;
                    else if (key === "BAT_CAPACITY") stats.batteryCapacityPath = value;
                    else if (key === "BAT_STATUS") stats.batteryStatusPath = value;
                }
                cpuTempFile.reload();
                gpuTempFile.reload();
                gpuBusyFile.reload();
                batteryCapacityFile.reload();
                batteryStatusFile.reload();
            }
        }
    }

    // Disk usage of the root filesystem, via `df` — there's no /proc file
    // for this, and it changes slowly, so it's polled on its own slower
    // timer rather than every pollTimer tick.
    property Process diskProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length < 2) return;
                const [sizeStr, usedStr] = lines[1].trim().split(/\s+/);
                const size = Number(sizeStr);
                const used = Number(usedStr);
                if (size > 0) {
                    stats.diskTotalGB = size / 1073741824;
                    stats.diskUsedGB = used / 1073741824;
                    stats.diskUsage = (used / size) * 100;
                }
            }
        }
    }

    property Timer diskPollTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProc.exec(["df", "-B1", "--output=size,used", "/"])
    }

    property Timer pollTimer: Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuStatFile.reload();
            memInfoFile.reload();
            if (stats.cpuTempPath !== "/dev/null") cpuTempFile.reload();
            if (stats.gpuTempPath !== "/dev/null") gpuTempFile.reload();
            if (stats.gpuBusyPath !== "/dev/null") gpuBusyFile.reload();
            if (stats.batteryCapacityPath !== "/dev/null") batteryCapacityFile.reload();
            if (stats.batteryStatusPath !== "/dev/null") batteryStatusFile.reload();
        }
    }
}
