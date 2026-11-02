pragma Singleton
import QtQuick
import Quickshell
import ZPreview

Singleton {
    property bool hasPlayer: true
    property bool playing: false
    property string title: "Neon Drift"
    property string artist: "Lumen Fields"
    property string album: "Night Signals"
    property string artUrl: "file://" + ZPreview.shellDir + "/preview/assets/cover.png"
    property string identity: "Player"
    property real position: 83
    property real length: 227
    readonly property real progress: length > 0 ? position / length : 0
    property bool canNext: true
    property bool canPrevious: true

    function toggle() {
        playing = !playing;
    }
    function next() {
    }
    function previous() {
    }
    function seek(f) {
        position = f * length;
    }
}
