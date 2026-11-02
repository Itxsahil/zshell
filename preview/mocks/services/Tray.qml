pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var items: []
    function iconFor(item) {
        return item?.icon ?? "";
    }
    function activate(item) {
    }
    function openMenu(item, hostWindow, x, y) {
    }
}
