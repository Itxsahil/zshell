pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property string type: "wifi"
    property string name: "homelab-5G"
    property int strength: 78
    readonly property bool connected: type !== "none"
    function refresh() {
    }
}
