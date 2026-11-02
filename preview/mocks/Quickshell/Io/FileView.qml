import QtQuick
import ZPreview

// Preview stand-in for Quickshell.Io.FileView (read-only, synchronous).
QtObject {
    id: root

    property string path
    property bool blockLoading: false
    property bool watchChanges: false
    property bool printErrors: true
    property string loadedText: ""
    property bool ready: false

    signal loaded
    signal loadFailed(int error)
    signal fileChanged

    function text() {
        return loadedText;
    }

    function reload() {
        if (!path)
            return;
        if (!ZPreview.exists(path)) {
            loadFailed(0);
            return;
        }
        loadedText = ZPreview.readFile(path);
        loaded();
    }

    onPathChanged: if (ready)
        reload()

    Component.onCompleted: {
        ready = true;
        reload();
    }
}
