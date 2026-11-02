import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.island

// Island mode: one large transparent layer surface at the top centre. Only
// the pill itself takes input (mask), so the rest is click-through, and only
// the collapsed height is reserved so the expanded pill floats over windows.
PanelWindow {
    id: win

    required property ShellScreen modelScreen

    screen: modelScreen
    color: "transparent"
    anchors.top: true
    margins.top: Theme.gap
    implicitWidth: 760
    implicitHeight: 620

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: (Config.options.layout?.reserveSpace ?? true) ? island.collapsedHeight + Theme.gap : 0

    WlrLayershell.namespace: "zshell-island"
    WlrLayershell.layer: WlrLayer.Top

    mask: Region {
        item: island.pill
    }

    IslandContent {
        id: island
        anchors.fill: parent
    }
}
