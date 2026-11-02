pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property real value: 0.7
    property bool available: true
    signal osdRequested(string kind)

    function set(v) {
        value = Math.max(0.01, Math.min(1, v));
        osdRequested("brightness");
    }
    function change(d) {
        set(value + d);
    }
    function refresh() {
    }
}
