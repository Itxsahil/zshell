import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.notifications

// Bar-mode notification toasts, top right.
PanelWindow {
    id: win

    required property ShellScreen modelScreen

    screen: modelScreen
    visible: Notifs.popups.count > 0
    color: "transparent"
    anchors {
        top: true
        right: true
    }
    margins {
        top: Theme.gap
        right: Theme.gap * 1.5
    }
    implicitWidth: stack.width
    implicitHeight: Math.max(1, stack.height)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0

    WlrLayershell.namespace: "zshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    ToastStack {
        id: stack
    }
}
