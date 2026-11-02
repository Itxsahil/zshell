pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The "current" MPRIS player: the one playing, else the first one found.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property MprisPlayer pinned: null

    readonly property MprisPlayer active: {
        if (pinned && players.indexOf(pinned) !== -1)
            return pinned;
        for (let i = 0; i < players.length; i++)
            if (players[i].isPlaying)
                return players[i];
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool hasPlayer: active !== null
    readonly property bool playing: active?.isPlaying ?? false
    readonly property string title: active?.trackTitle || "Unknown title"
    readonly property string artist: active?.trackArtist || ""
    readonly property string album: active?.trackAlbum || ""
    readonly property string artUrl: active?.trackArtUrl ?? ""
    readonly property string identity: active?.identity ?? ""
    readonly property real position: active?.position ?? 0
    readonly property real length: active?.length ?? 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0
    readonly property bool canNext: active?.canGoNext ?? false
    readonly property bool canPrevious: active?.canGoPrevious ?? false

    function toggle() {
        if (active?.canTogglePlaying)
            active.togglePlaying();
    }

    function next() {
        if (canNext)
            active.next();
    }

    function previous() {
        if (canPrevious)
            active.previous();
    }

    function seek(fraction) {
        if (active?.canSeek && length > 0)
            active.position = fraction * length;
    }

    // MPRIS position isn't pushed continuously; poke it while playing.
    Timer {
        running: root.playing
        interval: 1000
        repeat: true
        onTriggered: root.active?.positionChanged()
    }
}
