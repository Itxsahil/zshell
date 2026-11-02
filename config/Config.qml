pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Settings = built-in defaults (defaults/config.json) deep-merged with the
// user's overrides (~/.config/zshell/config.json).
//
// Only the overrides are ever written back, so updating zshell never clobbers
// your settings and your file stays small and readable.
//
// Read:  Config.options.appearance.glass.enabled
// Write: Config.set("appearance.glass.enabled", false)
Singleton {
    id: root

    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
    readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
    readonly property string dir: configHome + "/zshell"
    readonly property string stateDir: stateHome + "/zshell"
    readonly property string userPath: dir + "/config.json"

    property var defaults: ({})
    property var user: ({})

    // Everything binds to this. Re-assigning `user` or `defaults` produces a
    // new object, so every binding that reads Config.options re-evaluates.
    readonly property var options: merge(defaults, user)

    function get(path, fallback) {
        let node = options;
        for (const key of path.split(".")) {
            if (node === undefined || node === null)
                return fallback;
            node = node[key];
        }
        return node === undefined ? fallback : node;
    }

    function set(path, value) {
        const next = clone(user);
        const keys = path.split(".");
        let node = next;
        for (let i = 0; i < keys.length - 1; i++) {
            if (typeof node[keys[i]] !== "object" || node[keys[i]] === null)
                node[keys[i]] = {};
            node = node[keys[i]];
        }
        node[keys[keys.length - 1]] = value;
        user = next;
        save();
    }

    function toggle(path) {
        set(path, !get(path, false));
    }

    // Drop an override so the default applies again.
    function reset(path) {
        const next = clone(user);
        const keys = path.split(".");
        let node = next;
        for (let i = 0; i < keys.length - 1; i++) {
            node = node[keys[i]];
            if (typeof node !== "object" || node === null)
                return;
        }
        delete node[keys[keys.length - 1]];
        user = next;
        save();
    }

    function merge(base, over) {
        if (typeof base !== "object" || base === null || Array.isArray(base))
            return over === undefined ? base : over;
        const out = {};
        for (const k in base)
            out[k] = base[k];
        if (typeof over === "object" && over !== null && !Array.isArray(over)) {
            for (const k in over)
                out[k] = (k in base) ? merge(base[k], over[k]) : over[k];
        }
        return out;
    }

    function clone(obj) {
        return JSON.parse(JSON.stringify(obj ?? {}));
    }

    function parse(text, fallback) {
        if (!text || !text.trim())
            return fallback;
        try {
            return JSON.parse(text);
        } catch (e) {
            console.warn("zshell: could not parse config:", e.message, "- keeping previous values");
            return null;
        }
    }

    function save() {
        writer.pending = JSON.stringify(user, null, 2) + "\n";
        if (!writer.running)
            writer.flush();
    }

    FileView {
        path: Quickshell.shellDir + "/defaults/config.json"
        blockLoading: true
        onLoaded: root.defaults = root.parse(text(), {}) ?? root.defaults
    }

    FileView {
        id: userFile
        path: root.userPath
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const parsed = root.parse(text(), {});
            if (parsed !== null)
                root.user = parsed;
        }
        onLoadFailed: root.user = ({})
    }

    // Writes go through a tiny shell so the config dir is created on first save.
    Process {
        id: writer
        property string pending: ""

        function flush() {
            if (pending === "")
                return;
            command = ["sh", "-c", "mkdir -p \"$(dirname \"$1\")\" && printf '%s' \"$2\" > \"$1\"", "zshell", root.userPath, pending];
            pending = "";
            running = true;
        }

        onExited: flush()
    }
}
