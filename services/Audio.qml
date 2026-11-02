pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default sink/source volume via Pipewire. Emits osdRequested() whenever the
// volume or mute state changes from anywhere (keys, pavucontrol, scripts).
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool ready: sink?.ready ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property string sinkName: sink?.description ?? sink?.name ?? ""

    signal osdRequested(string kind)

    function setVolume(v) {
        if (!sink?.audio)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1.5, v));
    }

    function changeVolume(delta) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function setMicVolume(v) {
        if (!source?.audio)
            return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1.5, v));
    }

    function toggleMicMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    // Pipewire nodes only expose live properties while tracked.
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // Don't flash the OSD while devices bind at startup.
    property bool armed: false
    Timer {
        running: true
        interval: 1500
        onTriggered: root.armed = true
    }

    Connections {
        target: root.sink?.audio ?? null
        ignoreUnknownSignals: true
        function onVolumeChanged() {
            if (root.armed)
                root.osdRequested("volume");
        }
        function onMutedChanged() {
            if (root.armed)
                root.osdRequested("volume");
        }
    }

    Connections {
        target: root.source?.audio ?? null
        ignoreUnknownSignals: true
        function onMutedChanged() {
            if (root.armed)
                root.osdRequested("mic");
        }
    }
}
