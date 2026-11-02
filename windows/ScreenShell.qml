import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

// Everything zshell puts on one monitor. Layout mode switches live:
// LazyLoader destroys the bar and creates the island (or the reverse).
Scope {
    id: root

    required property ShellScreen modelData

    readonly property string mode: Config.options.layout?.mode ?? "bar"
    readonly property bool focused: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name === modelData.name : modelData === Quickshell.screens[0]
    readonly property bool drawWallpaper: (Config.options.appearance?.wallpaper?.backend ?? "zshell") === "zshell"

    LazyLoader {
        active: root.drawWallpaper
        WallpaperWindow {
            modelScreen: root.modelData
        }
    }

    LazyLoader {
        active: root.mode === "bar"
        BarWindow {
            screen: root.modelData
        }
    }

    LazyLoader {
        active: root.mode === "island"
        IslandWindow {
            modelScreen: root.modelData
        }
    }

    // In bar mode the OSD and toasts follow the focused monitor.
    LazyLoader {
        active: root.mode === "bar" && root.focused
        OsdWindow {
            modelScreen: root.modelData
        }
    }

    LazyLoader {
        active: root.mode === "bar" && root.focused
        ToastWindow {
            modelScreen: root.modelData
        }
    }
}
