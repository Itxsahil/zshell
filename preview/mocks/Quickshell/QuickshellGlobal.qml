pragma Singleton

import QtQuick
import ZPreview

// Preview stand-in for the `Quickshell` global.
QtObject {
    readonly property string shellDir: ZPreview.shellDir
    readonly property var screens: []

    function env(name) {
        return ZPreview.env(name);
    }

    function iconPath(name, check) {
        return "";
    }
}
