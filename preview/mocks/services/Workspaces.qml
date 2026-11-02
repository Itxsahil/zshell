pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {
    property int focusedId: 2
    property var occupied: ({
            1: true,
            2: true,
            3: true,
            5: true
        })
    readonly property int count: Math.max(Config.options.layout?.workspaces ?? 5, focusedId)
    property string activeTitle: "nvim ~/zshell/modules/island/IslandContent.qml"
    property string activeClass: "kitty"

    function focus(id) {
        focusedId = id;
    }
    function scroll(step) {
        focusedId = Math.max(1, focusedId + step);
    }
}
