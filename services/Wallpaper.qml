pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Current wallpaper + optional matugen run so the theme follows it.
Singleton {
    id: root

    readonly property var opts: Config.options.appearance?.wallpaper ?? ({})
    readonly property string path: expand(opts.path ?? "")
    readonly property string directory: expand(opts.directory ?? "~/Pictures/Wallpapers")
    property var files: []

    function expand(p) {
        return p.startsWith("~/") ? Quickshell.env("HOME") + p.slice(1) : p;
    }

    function set(file) {
        Config.set("appearance.wallpaper.path", file);
        if (opts.autoTheme ?? true)
            generateTheme(file);
    }

    function random() {
        if (files.length === 0)
            return;
        let pick = files[Math.floor(Math.random() * files.length)];
        if (files.length > 1)
            while (pick === path)
                pick = files[Math.floor(Math.random() * files.length)];
        set(pick);
    }

    function generateTheme(file) {
        if (Config.options.appearance?.theme?.source !== "dynamic")
            return;
        const mode = Config.options.appearance?.theme?.mode ?? "dark";
        const variant = Config.options.appearance?.theme?.variant ?? "scheme-tonal-spot";
        matugen.command = ["matugen", "-c", Quickshell.shellDir + "/matugen/config.toml", "image", file, "-m", mode, "-t", variant];
        matugen.running = true;
    }

    function scan() {
        lister.running = true;
    }

    onDirectoryChanged: scan()
    Component.onCompleted: scan()

    Process {
        id: lister
        command: ["find", root.directory, "-maxdepth", "2", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"]
        stdout: StdioCollector {
            onStreamFinished: root.files = text.split("\n").filter(l => l.length > 0).sort()
        }
    }

    Process {
        id: matugen
    }
}
