pragma Singleton
import Quickshell.Io
import QtQuick
import "."

// Reads and drives Wi-Fi (NetworkManager), Bluetooth (bluetoothctl), volume
// (wpctl/PipeWire) and screen brightness (brightnessctl, if installed).
// Unlike SystemStats (plain file reads), these all shell out to real
// commands, so polling only runs while the control center is actually open.
QtObject {
    id: ctrl

    property bool wifiEnabled: false
    property string wifiSSID: ""
    // [{ssid, signal, secured, active}], deduped and sorted by signal.
    property var wifiNetworks: []
    property string wifiConnectingSsid: ""
    // Non-empty means "show a password field for this network" — set after
    // a connect attempt fails, since that's the common reason (an unsaved
    // secured network).
    property string wifiPasswordSsid: ""
    property string wifiError: ""
    property string _pendingWifiSsid: ""
    property bool _pendingWifiSecured: false

    property bool bluetoothEnabled: false
    property string bluetoothDevice: ""
    // [{mac, name, paired, connected}] — every device bluetoothd currently
    // knows about (paired, or just seen while scanning), paired ones first.
    property var bluetoothDevices: []
    property string bluetoothConnectingMac: ""

    property real volume: 0       // 0-1
    property bool volumeMuted: false

    property bool brightnessAvailable: false
    property real brightness: 0   // 0-1

    function refreshStatus() {
        _statusProc.exec(["bash", "-c",
            "echo \"WIFI_ENABLED=$(nmcli radio wifi)\"; " +
            "ssid=$(nmcli -t -f NAME,TYPE connection show --active | grep \":802-11-wireless$\" | head -1 | cut -d: -f1); " +
            "echo \"WIFI_SSID=$ssid\"; " +
            "if bluetoothctl show | grep -q \"Powered: yes\"; then echo \"BT_ENABLED=yes\"; else echo \"BT_ENABLED=no\"; fi; " +
            "btdev=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d\" \" -f3-); " +
            "echo \"BT_DEVICE=$btdev\""
        ]);
    }

    // Uses cached scan results (--rescan no) — forcing a rescan takes
    // several seconds, which would make the panel feel like it's hanging.
    function refreshWifiNetworks() {
        _wifiListProc.exec(["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL,ACTIVE", "dev", "wifi", "list", "--rescan", "no"]);
    }

    // "devices" (no filter) is every device bluetoothd currently knows
    // about — while a scan is running (see startBluetoothScan()) that
    // includes newly-discovered nearby devices, not just paired ones.
    function refreshBluetoothDevices() {
        _btListProc.exec(["bash", "-c",
            "bluetoothctl devices | sed 's/^/SEEN /'; " +
            "bluetoothctl devices Paired | sed 's/^/PAIRED /'; " +
            "bluetoothctl devices Connected | sed 's/^/CONNECTED /'"
        ]);
    }

    function refreshVolume() {
        _volumeProc.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
    }

    function refreshBrightness() {
        _brightnessProc.exec(["bash", "-c",
            "command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m | cut -d',' -f4 || echo NONE"
        ]);
    }

    function toggleWifi() {
        wifiEnabled = !wifiEnabled; // optimistic — nmcli takes a moment
        _actionProc.exec(["nmcli", "radio", "wifi", wifiEnabled ? "on" : "off"]);
        _refreshDelay.restart();
    }

    function toggleBluetooth() {
        bluetoothEnabled = !bluetoothEnabled;
        _btActionProc.exec(["bluetoothctl", "power", bluetoothEnabled ? "on" : "off"]);
        _refreshDelay.restart();
    }

    // Tapping a network: if it's the one already showing a password field,
    // tapping it again closes that field. If it's the currently-active
    // network, tapping it disconnects — tapping it again reconnects, same
    // as any other network. Otherwise, try activating any existing saved
    // profile first; if none exists, secured networks need a password
    // (opens right under it, see wifiPasswordSsid) but open ones just
    // connect directly.
    function selectWifiNetwork(ssid, active, secured) {
        if (ctrl.wifiPasswordSsid === ssid) {
            wifiPasswordSsid = "";
            wifiError = "";
            return;
        }
        if (ctrl.wifiConnectingSsid === ssid) return;
        if (active) {
            disconnectWifi(ssid);
            return;
        }
        wifiPasswordSsid = "";
        wifiError = "";
        _pendingWifiSecured = secured;
        wifiConnectingSsid = ssid;
        _pendingWifiSsid = ssid;
        // --wait bounds how long a failed/out-of-range attempt blocks —
        // NetworkManager's own default activation timeout is ~90s, and
        // activating *any* network first disconnects whatever's currently
        // active, so a slow failure here would mean a long unwanted outage.
        _wifiActivateProc.exec(["nmcli", "--wait", "15", "connection", "up", "id", ssid]);
    }

    function disconnectWifi(ssid) {
        wifiConnectingSsid = ssid;
        _wifiDisconnectProc.exec(["nmcli", "connection", "down", "id", ssid]);
    }

    function submitWifiPassword(password) {
        if (!password) return;
        _createWifiConnection(wifiPasswordSsid, password);
    }

    // Creating (or modifying) a *system-wide* connection needs a polkit
    // "auth" permission, and this session has no polkit agent running to
    // grant it — that's why connections created via the plain
    // `nmcli device wifi connect ... password ...` path silently failed to
    // save, so it kept re-asking for the password every time. Scoping the
    // new connection to just this user only needs "settings.modify.own"
    // instead, which is already allowed without any agent — see
    // `nmcli general permissions`.
    function _createWifiConnection(ssid, password) {
        _pendingWifiSsid = ssid;
        wifiConnectingSsid = ssid;
        const script = password
            ? 'nmcli connection delete id "$1" >/dev/null 2>&1; ' +
              'nmcli connection add type wifi ifname "*" con-name "$1" ssid "$1" autoconnect yes save yes -- ' +
              'wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$2" connection.permissions "user:$(whoami)" ' +
              '&& nmcli --wait 15 connection up id "$1"'
            : 'nmcli connection delete id "$1" >/dev/null 2>&1; ' +
              'nmcli connection add type wifi ifname "*" con-name "$1" ssid "$1" autoconnect yes save yes -- ' +
              'connection.permissions "user:$(whoami)" ' +
              '&& nmcli --wait 15 connection up id "$1"';
        _wifiConnectProc.exec(["bash", "-c", script, "_", ssid, password || ""]);
    }

    function cancelWifiPassword() {
        wifiPasswordSsid = "";
        wifiError = "";
    }

    function selectBluetoothDevice(mac, connected, paired) {
        if (ctrl.bluetoothConnectingMac === mac) return;
        bluetoothConnectingMac = mac;
        if (!paired) {
            // --timeout bounds this: some devices need an interactive PIN/
            // passkey confirmation we can't provide headlessly, and without
            // a limit bluetoothctl would just hang waiting for it. Simple
            // "just works" devices (most headphones, mice, etc.) pair well
            // within this.
            _btPairProc.exec(["bash", "-c",
                'bluetoothctl --timeout 15 pair "$1" && bluetoothctl connect "$1"',
                "_", mac
            ]);
            return;
        }
        _btConnectProc.exec(["bluetoothctl", connected ? "disconnect" : "connect", mac]);
    }

    // A one-shot `bluetoothctl scan on` doesn't actually keep scanning —
    // BlueZ stops discovery as soon as the requesting client disconnects,
    // and a non-interactive invocation exits immediately. So instead this
    // keeps one bluetoothctl REPL alive for the whole session and drives it
    // over stdin, the same way you'd type into it interactively.
    function startBluetoothScan() {
        if (!_btScanProc.running) _btScanProc.running = true;
        _btScanProc.write("scan on\n");
    }

    function stopBluetoothScan() {
        if (_btScanProc.running) _btScanProc.write("scan off\n");
    }

    function setVolume(v) {
        volume = Math.min(Math.max(v, 0), 1);
        volumeMuted = false;
        _volumeSetProc.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volume.toFixed(2)]);
    }

    function setBrightness(v) {
        brightness = Math.min(Math.max(v, 0), 1);
        _brightnessSetProc.exec(["brightnessctl", "set", Math.round(brightness * 100) + "%"]);
    }

    property Process _statusProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const idx = line.indexOf("=");
                    if (idx < 0) continue;
                    const key = line.slice(0, idx);
                    const value = line.slice(idx + 1);
                    if (key === "WIFI_ENABLED") ctrl.wifiEnabled = value === "enabled";
                    else if (key === "WIFI_SSID") ctrl.wifiSSID = value;
                    else if (key === "BT_ENABLED") ctrl.bluetoothEnabled = value === "yes";
                    else if (key === "BT_DEVICE") ctrl.bluetoothDevice = value;
                }
            }
        }
    }

    property Process _wifiListProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                // Mesh/repeater setups report the same SSID many times at
                // different signal strengths — dedupe to the strongest one,
                // but keep "active"/"secured" if true on any duplicate.
                const byName = {};
                for (const line of text.trim().split("\n")) {
                    if (!line) continue;
                    const parts = line.split(":");
                    if (parts.length < 4) continue;
                    const active = parts[parts.length - 1] === "yes";
                    const signal = Number(parts[parts.length - 2]) || 0;
                    const security = parts[parts.length - 3];
                    const ssid = parts.slice(0, parts.length - 3).join(":");
                    if (!ssid) continue; // hidden networks show up blank
                    const secured = security !== "" && security !== "--";
                    const existing = byName[ssid];
                    if (!existing) {
                        byName[ssid] = { ssid, signal, secured, active };
                    } else {
                        existing.signal = Math.max(existing.signal, signal);
                        existing.active = existing.active || active;
                        existing.secured = existing.secured || secured;
                    }
                }
                ctrl.wifiNetworks = Object.values(byName).sort((a, b) => b.signal - a.signal);
            }
        }
    }

    property Process _btListProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const names = {};
                const paired = new Set();
                const connected = new Set();
                for (const line of text.trim().split("\n")) {
                    const m = line.match(/^(SEEN|PAIRED|CONNECTED) Device (\S+) (.+)$/);
                    if (!m) continue;
                    const [, kind, mac, name] = m;
                    if (kind === "SEEN") names[mac] = name;
                    else if (kind === "PAIRED") paired.add(mac);
                    else connected.add(mac);
                }
                const list = Object.keys(names).map(mac => ({
                    mac,
                    name: names[mac],
                    paired: paired.has(mac),
                    connected: connected.has(mac)
                }));
                // Paired devices first, then alphabetical.
                list.sort((a, b) => (b.paired - a.paired) || a.name.localeCompare(b.name));
                ctrl.bluetoothDevices = list;
            }
        }
    }

    property Process _volumeProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/Volume:\s*([\d.]+)/);
                if (m) ctrl.volume = Number(m[1]);
                ctrl.volumeMuted = text.includes("MUTED");
            }
        }
    }

    property Process _brightnessProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                if (t === "NONE" || t === "") {
                    ctrl.brightnessAvailable = false;
                    return;
                }
                ctrl.brightnessAvailable = true;
                ctrl.brightness = Number(t.replace("%", "")) / 100;
            }
        }
    }

    property Process _actionProc: Process {}
    property Process _btActionProc: Process {}
    property Process _volumeSetProc: Process {}
    property Process _brightnessSetProc: Process {}

    // Tries an existing profile (own or system) first — this is the fast,
    // no-password path for any network already known, including ones that
    // predate this app. Failing (most commonly: no profile exists yet)
    // falls through to creating one.
    property Process _wifiActivateProc: Process {
        onExited: (exitCode) => {
            if (exitCode === 0) {
                ctrl.wifiConnectingSsid = "";
                ctrl.refreshWifiNetworks();
                ctrl.refreshStatus();
                return;
            }
            if (ctrl._pendingWifiSecured) {
                ctrl.wifiConnectingSsid = "";
                ctrl.wifiPasswordSsid = ctrl._pendingWifiSsid;
            } else {
                ctrl._createWifiConnection(ctrl._pendingWifiSsid, "");
            }
        }
    }

    property Process _wifiConnectProc: Process {
        stderr: StdioCollector { id: _wifiConnectErr }
        onExited: (exitCode) => {
            ctrl.wifiConnectingSsid = "";
            if (exitCode === 0) {
                ctrl.wifiPasswordSsid = "";
                ctrl.wifiError = "";
                ctrl.refreshWifiNetworks();
                ctrl.refreshStatus();
            } else {
                ctrl.wifiPasswordSsid = ctrl._pendingWifiSsid;
                ctrl.wifiError = "Couldn't connect to " + ctrl._pendingWifiSsid;
            }
        }
    }

    property Process _wifiDisconnectProc: Process {
        onExited: (exitCode) => {
            ctrl.wifiConnectingSsid = "";
            ctrl.refreshWifiNetworks();
            ctrl.refreshStatus();
        }
    }

    property Process _btConnectProc: Process {
        onExited: (exitCode) => {
            ctrl.bluetoothConnectingMac = "";
            ctrl.refreshBluetoothDevices();
            ctrl.refreshStatus();
        }
    }

    property Process _btPairProc: Process {
        onExited: (exitCode) => {
            ctrl.bluetoothConnectingMac = "";
            ctrl.refreshBluetoothDevices();
            ctrl.refreshStatus();
        }
    }

    // Kept alive for the whole session rather than spawned fresh per scan —
    // see startBluetoothScan()/stopBluetoothScan() above.
    property Process _btScanProc: Process {
        command: ["bluetoothctl"]
        stdinEnabled: true
    }

    // nmcli/bluetoothctl don't apply instantly — re-poll shortly after a
    // toggle to correct the optimistic UI update if it didn't take.
    property Timer _refreshDelay: Timer {
        interval: 800
        onTriggered: ctrl.refreshStatus()
    }

    property Timer pollTimer: Timer {
        interval: 3000
        running: ControlCenterState.open
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ctrl.refreshStatus();
            ctrl.refreshWifiNetworks();
            ctrl.refreshBluetoothDevices();
            ctrl.refreshVolume();
            ctrl.refreshBrightness();
        }
        onRunningChanged: {
            if (!running) {
                ctrl.wifiPasswordSsid = "";
                ctrl.wifiError = "";
            }
        }
    }
}
