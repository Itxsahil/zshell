pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property real volume: 0.62
    property bool muted: false
    property real micVolume: 0.8
    property bool micMuted: false
    readonly property bool ready: true
    readonly property string sinkName: "Speakers"
    signal osdRequested(string kind)

    function setVolume(v) {
        muted = false;
        volume = Math.max(0, Math.min(1.5, v));
        osdRequested("volume");
    }
    function changeVolume(d) {
        setVolume(volume + d);
    }
    function toggleMute() {
        muted = !muted;
        osdRequested("volume");
    }
    function setMicVolume(v) {
        micVolume = v;
        osdRequested("mic");
    }
    function toggleMicMute() {
        micMuted = !micMuted;
        osdRequested("mic");
    }
}
