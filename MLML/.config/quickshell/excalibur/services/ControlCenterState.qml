pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    // Which sub-view the control center pill is showing — "menu" is the
    // Wi-Fi/Bluetooth/volume/brightness list, "wifi"/"bluetooth" are the
    // full network/device picker views you drill into from it.
    property string view: "menu"

    function show() { open = true; }
    function hide() { open = false; view = "menu"; }
    function toggle() { open ? hide() : show(); }

    function showMenu() { view = "menu"; }
    function showWifiList() { view = "wifi"; }
    function showBluetoothList() { view = "bluetooth"; }
}
