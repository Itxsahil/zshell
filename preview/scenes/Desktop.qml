import QtQuick
import QtQuick.Effects
import qs.config

// Fake Hyprland desktop: wallpaper + two tiled windows, plus a blurred copy
// standing in for Hyprland's blur (sampled by GlassSurface).
Item {
    id: root

    property real topInset: 64
    property bool showWindows: true
    default property alias shell: shellLayer.data

    width: 1920
    height: 1080

    readonly property var blur: Glass.blur
    readonly property real blurPx: Math.min(64, (blur.size ?? 8) * (blur.passes ?? 3) * 2)

    function kw(word, color) {
        return "<font color='" + color + "'>" + word + "</font>";
    }

    MultiEffect {
        id: blurred
        anchors.fill: parent
        source: scene
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 64
        blur: root.blurPx / 64
        brightness: ((root.blur.brightness ?? 0.85) - 1) * 0.6
        contrast: ((root.blur.contrast ?? 0.9) - 1) * 0.6
        saturation: (root.blur.vibrancy ?? 0.2) * 0.8
    }

    Item {
        id: scene
        anchors.fill: parent

        WallpaperArt {
            anchors.fill: parent
        }

        Item {
            visible: root.showWindows
            anchors.fill: parent
            anchors.topMargin: root.topInset
            anchors.margins: 16

            FakeWindow {
                id: term
                x: 0
                y: 0
                width: parent.width * 0.42
                height: parent.height
                body: {
                    const p = Theme.primary, s = Theme.subtext, g = Theme.success, sc = Theme.secondary;
                    return root.kw("~/zshell", sc) + " " + root.kw("❯", g) + " fastfetch --logo none<br>" + root.kw("user", p) + "@" + root.kw("arch", p) + "<br>" + root.kw("OS", p) + "      Arch Linux x86_64<br>" + root.kw("WM", p) + "      Hyprland<br>" + root.kw("Shell", p) + "   zsh 5.9<br>" + root.kw("Bar", p) + "     zshell · " + Theme.name + "<br>" + root.kw("Font", p) + "    Inter, JetBrains Mono<br><br>" + root.kw("~/zshell", sc) + " " + root.kw("❯", g) + " qs -c zshell ipc call glass preset frosted<br>" + root.kw("~/zshell", sc) + " " + root.kw("❯", g) + " qs -c zshell ipc call layout toggle<br>" + root.kw("~/zshell", sc) + " " + root.kw("❯", g) + " git log --oneline<br>" + root.kw("a1f3c9e", Theme.warning) + " island: spring-animate pill size<br>" + root.kw("7be20d4", Theme.warning) + " glass: live blur sliders via hyprctl<br>" + root.kw("4c81aa0", Theme.warning) + " theme: preset + matugen palettes<br>" + root.kw("9d0e6b2", Theme.warning) + " services: pipewire, mpris, upower<br><br>" + root.kw("~/zshell", sc) + " " + root.kw("❯", g) + " █";
                }
            }

            FakeWindow {
                focused: true
                x: term.width + 16
                y: 0
                width: parent.width - term.width - 16
                height: parent.height
                fontSize: 14
                body: {
                    const k = Theme.tertiary, t = Theme.secondary, s = Theme.success, c = Theme.subtext, p = Theme.primary;
                    return root.kw("// modules/island/IslandContent.qml", c) + "<br>" + root.kw("import", k) + " QtQuick<br>" + root.kw("import", k) + " qs.config<br>" + root.kw("import", k) + " qs.services<br><br>" + root.kw("Item", t) + " {<br>&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("id", p) + ": root<br><br>&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("readonly property", k) + " " + root.kw("string", t) + " mode: expanded<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;? " + root.kw("\"dashboard\"", s) + " : Activity.current<br><br>&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("Item", t) + " {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("id", p) + ": pill<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;width: root.showBody ? root.bodyWidth<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: topRow.implicitWidth + 36<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("Behavior on", k) + " width {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("SpringAnimation", t) + " { spring: " + root.kw("3.6", Theme.warning) + "; damping: " + root.kw("0.34", Theme.warning) + " }<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + root.kw("GlassSurface", t) + " {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;anchors.fill: parent<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;surface: " + root.kw("\"island\"", s) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br>}";
                }
            }
        }
    }

    Item {
        id: shellLayer
        anchors.fill: parent
    }

    Component.onCompleted: Glass.previewBackdrop = blurred
}
