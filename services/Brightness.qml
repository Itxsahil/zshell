pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness via brightnessctl. Bind your brightness keys to
// `qs -c zshell ipc call brightness up|down` so changes show in the OSD.
Singleton {
    id: root

    property real value: 0
    property bool available: false

    signal osdRequested(string kind)

    function set(v) {
        if (!available)
            return;
        value = Math.max(0.01, Math.min(1, v));
        setter.command = ["brightnessctl", "-q", "set", Math.round(value * 100) + "%"];
        setter.running = true;
        osdRequested("brightness");
    }

    function change(delta) {
        set(value + delta);
    }

    function refresh() {
        reader.running = true;
    }

    Component.onCompleted: refresh()

    // `brightnessctl -m info` → "intel_backlight,backlight,512,50%,1024"
    Process {
        id: reader
        command: ["brightnessctl", "-m", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                const cur = parseInt(parts[2]);
                const max = parseInt(parts[4]);
                if (parts[1] === "backlight" && max > 0) {
                    root.value = cur / max;
                    root.available = true;
                }
            }
        }
    }

    Process {
        id: setter
    }
}
