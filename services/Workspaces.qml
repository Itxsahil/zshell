pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config

Singleton {
    id: root

    readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property int minimum: Config.options.layout?.workspaces ?? 5

    // id -> true for workspaces that have windows
    readonly property var occupied: {
        const map = {};
        const values = Hyprland.workspaces.values;
        for (let i = 0; i < values.length; i++) {
            const ws = values[i];
            if (ws.id > 0)
                map[ws.id] = ws.toplevels ? ws.toplevels.values.length > 0 : true;
        }
        return map;
    }

    // Always show `minimum` slots, more if a higher workspace is in use.
    readonly property int count: {
        let highest = Math.max(minimum, focusedId);
        for (const id in occupied)
            if (occupied[id])
                highest = Math.max(highest, parseInt(id));
        return highest;
    }

    readonly property string activeTitle: ToplevelManager.activeToplevel?.title ?? ""
    readonly property string activeClass: ToplevelManager.activeToplevel?.appId ?? ""

    function focus(id) {
        Hyprland.dispatch("workspace " + id);
    }

    function scroll(step) {
        Hyprland.dispatch("workspace " + (step > 0 ? "r+1" : "r-1"));
    }
}
