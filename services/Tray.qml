pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    readonly property var items: SystemTray.items.values

    function iconFor(item) {
        return item?.icon ?? "";
    }

    function activate(item) {
        item?.activate();
    }

    // hostWindow is the PanelWindow the tray row lives in; x/y are relative to it.
    function openMenu(item, hostWindow, x, y) {
        if (!item)
            return;
        if (item.hasMenu && hostWindow)
            item.display(hostWindow, x, y);
        else
            item.secondaryActivate();
    }
}
