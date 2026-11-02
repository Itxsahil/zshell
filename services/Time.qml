pragma Singleton

import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(clock.date, Config.options.clock?.timeFormat ?? "hh:mm")
    readonly property string date: Qt.formatDateTime(clock.date, Config.options.clock?.dateFormat ?? "ddd d MMM")
    readonly property string longDate: Qt.formatDateTime(clock.date, "dddd, d MMMM")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
