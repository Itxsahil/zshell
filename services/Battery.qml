pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool available: device?.isLaptopBattery ?? false
    // UPower reports 0-1 in current Quickshell, 0-100 in older builds.
    readonly property real percent: {
        const p = device?.percentage ?? 0;
        return p > 1 ? p / 100 : p;
    }
    readonly property bool charging: device?.state === UPowerDeviceState.Charging || device?.state === UPowerDeviceState.PendingCharge
    readonly property bool full: device?.state === UPowerDeviceState.FullyCharged
    readonly property bool onBattery: UPower.onBattery
    readonly property real timeToEmpty: device?.timeToEmpty ?? 0
    readonly property real timeToFull: device?.timeToFull ?? 0
}
