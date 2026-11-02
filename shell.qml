//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.services
import qs.windows

// zshell entry point.  Run with:  qs -c zshell
//
//   config/      settings, theme tokens, glass       (Quickshell singletons)
//   services/    system state: audio, media, ...     (Quickshell singletons)
//   components/  shared widgets                      (plain QtQuick)
//   modules/     bar, island, dashboard, osd, toasts (plain QtQuick)
//   windows/     layer-shell windows that place modules on screen
ShellRoot {
    Variants {
        model: Quickshell.screens

        ScreenShell {}
    }

    Ipc {}

    // `hyprctl reload` resets blur to hyprland.conf values; re-apply ours.
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded")
                Glass.applyToHyprland();
        }
    }

    // Singletons are lazy; make sure the notification daemon and the blur
    // settings are live from the start, whatever layout is active.
    Component.onCompleted: {
        Notifs.dnd;
        Activity.current;
        Glass.enabled;
    }
}
