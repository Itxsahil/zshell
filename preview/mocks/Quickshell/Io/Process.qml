import QtQuick
import ZPreview

// Preview stand-in for Quickshell.Io.Process: logs the command, runs nothing.
QtObject {
    id: root

    property var command: []
    property bool running: false
    property var stdout: null
    property var stderr: null

    signal started
    signal exited(int exitCode, int exitStatus)

    onRunningChanged: {
        if (!running)
            return;
        ZPreview.log("[process] " + command.join(" "));
        running = false;
        exited(0, 0);
    }
}
