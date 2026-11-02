import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.modules.bar
import qs.modules.dashboard
import qs.components

// Bar mode: the bar plus its dashboard dropdown, for one screen.
Scope {
    id: root

    required property ShellScreen screen
    readonly property bool atTop: (Config.options.layout?.position ?? "top") !== "bottom"
    readonly property bool floating: Config.options.layout?.floating ?? true
    property bool dashboardOpen: false

    PanelWindow {
        id: bar

        screen: root.screen
        color: "transparent"
        anchors {
            top: root.atTop
            bottom: !root.atTop
            left: true
            right: true
        }
        margins {
            top: root.floating && root.atTop ? Theme.gap : 0
            bottom: root.floating && !root.atTop ? Theme.gap : 0
            left: root.floating ? Theme.gap * 1.5 : 0
            right: root.floating ? Theme.gap * 1.5 : 0
        }
        implicitHeight: content.implicitHeight
        exclusionMode: (Config.options.layout?.reserveSpace ?? true) ? ExclusionMode.Auto : ExclusionMode.Ignore

        WlrLayershell.namespace: "zshell-bar"
        WlrLayershell.layer: WlrLayer.Top

        BarContent {
            id: content
            anchors.fill: parent
            hostWindow: bar
            onDashboardRequested: root.dashboardOpen = !root.dashboardOpen
        }
    }

    PanelWindow {
        id: dropdown

        screen: root.screen
        visible: root.dashboardOpen
        color: "transparent"
        anchors {
            top: root.atTop
            bottom: !root.atTop
        }
        margins {
            top: Theme.gap
            bottom: Theme.gap
        }
        implicitWidth: 460
        implicitHeight: dash.implicitHeight + 40
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0

        WlrLayershell.namespace: "zshell-panel"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        // Clicking anywhere outside closes the dropdown.
        HyprlandFocusGrab {
            windows: [dropdown, bar]
            active: dropdown.visible
            onCleared: root.dashboardOpen = false
        }

        GlassSurface {
            anchors.fill: parent
            surface: "popup"
            radius: Theme.radius * 1.4
        }

        Dashboard {
            id: dash
            anchors.fill: parent
            anchors.margins: 20
        }
    }
}
