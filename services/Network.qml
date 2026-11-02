pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Connection state via nmcli. Event-driven: `nmcli monitor` prints a line on
// every change, which triggers one status query (no polling loop).
Singleton {
    id: root

    property string type: "none"   // "ethernet" | "wifi" | "none"
    property string name: ""
    property int strength: 0       // wifi signal 0-100

    readonly property bool connected: type !== "none"

    function refresh() {
        if (!status.running)
            status.running = true;
    }

    // nmcli -t escapes ':' inside values as '\:'; CONNECTION is the last
    // field so everything after the second separator is the name.
    function parse(output) {
        const [devices, wifi] = output.split("---");
        let found = {
            type: "none",
            name: ""
        };
        for (const line of (devices ?? "").trim().split("\n")) {
            const first = line.indexOf(":");
            const second = line.indexOf(":", first + 1);
            if (first < 0 || second < 0)
                continue;
            const devType = line.slice(0, first);
            const state = line.slice(first + 1, second);
            const conn = line.slice(second + 1).replace(/\\:/g, ":");
            if (state !== "connected")
                continue;
            if (devType === "ethernet") {
                found = {
                    type: "ethernet",
                    name: conn
                };
                break;
            }
            if (devType === "wifi" && found.type === "none")
                found = {
                    type: "wifi",
                    name: conn
                };
        }
        type = found.type;
        name = found.name;
        const wifiLine = (wifi ?? "").trim().split("\n").find(l => l.startsWith("yes:"));
        strength = wifiLine ? parseInt(wifiLine.split(":")[1]) || 0 : 0;
    }

    Component.onCompleted: refresh()

    Process {
        id: monitor
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: root.refresh()
    }

    Process {
        id: status
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device; echo ---; nmcli -t -f ACTIVE,SIGNAL device wifi 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }
}
