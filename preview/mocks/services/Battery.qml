pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property bool available: true
    property real percent: 0.76
    property bool charging: false
    property bool full: false
    property bool onBattery: true
    property real timeToEmpty: 15800
    property real timeToFull: 0
}
