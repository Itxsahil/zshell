pragma Singleton
import QtQuick
import Quickshell
import qs.config

// Frozen clock so screenshots are reproducible.
Singleton {
    property date now: new Date(2026, 10, 1, 14, 32)
    readonly property string time: Qt.formatDateTime(now, Config.options.clock?.timeFormat ?? "hh:mm")
    readonly property string date: Qt.formatDateTime(now, Config.options.clock?.dateFormat ?? "ddd d MMM")
    readonly property string longDate: Qt.formatDateTime(now, "dddd, d MMMM")
}
