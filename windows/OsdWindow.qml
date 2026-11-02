import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.osd

// Bar-mode OSD, bottom centre. Click-through (empty mask).
PanelWindow {
    id: win

    required property ShellScreen modelScreen

    screen: modelScreen
    visible: osd.animating
    color: "transparent"
    anchors.bottom: true
    margins.bottom: 90
    implicitWidth: osd.implicitWidth + 20
    implicitHeight: osd.implicitHeight + 20
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "zshell-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    mask: Region {}

    OsdContent {
        id: osd
        anchors.centerIn: parent
    }
}
