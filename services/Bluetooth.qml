pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false

    readonly property var connected: {
        const list = [];
        const values = Bluetooth.devices.values;
        for (let i = 0; i < values.length; i++)
            if (values[i].connected)
                list.push(values[i]);
        return list;
    }

    function toggle() {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }
}
