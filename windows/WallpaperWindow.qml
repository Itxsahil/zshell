import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

// Draws the wallpaper on the background layer with a crossfade, so no
// swww/hyprpaper is needed. Disabled when appearance.wallpaper.backend != "zshell".
PanelWindow {
    id: win

    required property ShellScreen modelScreen

    screen: modelScreen
    color: Theme.base
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "zshell-wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    property string shown: ""
    property bool frontIsA: true

    function show(path) {
        if (!path || path === shown)
            return;
        shown = path;
        const next = frontIsA ? b : a;
        next.source = "file://" + path;
    }

    Component.onCompleted: show(Wallpaper.path)

    Connections {
        target: Wallpaper
        function onPathChanged() {
            win.show(Wallpaper.path);
        }
    }

    component Layer: Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize.width: win.width
        sourceSize.height: win.height
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.dur(Config.options.appearance?.wallpaper?.transitionMs ?? 600)
                easing.type: Easing.InOutQuad
            }
        }
    }

    Layer {
        id: a
        onStatusChanged: if (status === Image.Ready && !win.frontIsA) {
            z = 1;
            b.z = 0;
            opacity = 1;
            win.frontIsA = true;
            fadeOut.start();
        }
    }

    Layer {
        id: b
        onStatusChanged: if (status === Image.Ready && win.frontIsA) {
            z = 1;
            a.z = 0;
            opacity = 1;
            win.frontIsA = false;
            fadeOut.start();
        }
    }

    // Hide the old layer once the new one has fully faded in.
    Timer {
        id: fadeOut
        interval: Config.options.appearance?.wallpaper?.transitionMs ?? 600
        onTriggered: (win.frontIsA ? b : a).opacity = 0
    }
}
