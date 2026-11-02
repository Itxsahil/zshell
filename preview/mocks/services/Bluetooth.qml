pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property bool available: true
    property bool enabled: true
    property var connected: [
        {
            name: "Buds Pro"
        }
    ]
    function toggle() {
        enabled = !enabled;
    }
}
