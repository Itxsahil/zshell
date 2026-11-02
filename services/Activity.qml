pragma Singleton

import QtQuick
import Quickshell
import qs.config

// Decides what deserves attention right now. Bar mode uses osd* for the OSD
// popup; island mode uses `current` to pick what the pill shows.
//
// Priority: notification > osd > media > idle
Singleton {
    id: root

    // ---- OSD ---------------------------------------------------------------
    property string osdKind: "volume"   // "volume" | "mic" | "brightness"
    property bool osdVisible: false

    readonly property real osdValue: osdKind === "brightness" ? Brightness.value : osdKind === "mic" ? Audio.micVolume : Audio.volume
    readonly property bool osdMuted: osdKind === "mic" ? Audio.micMuted : osdKind === "volume" ? Audio.muted : false
    readonly property string osdIcon: {
        if (osdKind === "brightness")
            return osdValue > 0.66 ? "brightness_high" : osdValue > 0.33 ? "brightness_medium" : "brightness_low";
        if (osdKind === "mic")
            return osdMuted ? "mic_off" : "mic";
        if (osdMuted || osdValue <= 0)
            return "volume_off";
        return osdValue > 0.5 ? "volume_up" : "volume_down";
    }

    function showOsd(kind) {
        osdKind = kind;
        osdVisible = true;
        osdTimer.restart();
    }

    // ---- Notification spotlight (island) ---------------------------------
    property var spotlight: null
    property bool spotlightHeld: false

    function showNotification(n) {
        spotlight = n;
        if (!spotlightHeld)
            spotlightTimer.restart();
    }

    function holdSpotlight(hold) {
        spotlightHeld = hold;
        if (hold)
            spotlightTimer.stop();
        else if (spotlight)
            spotlightTimer.restart();
    }

    function clearSpotlight() {
        spotlight = null;
        spotlightHeld = false;
        spotlightTimer.stop();
    }

    // ---- Island state ------------------------------------------------------
    readonly property string current: spotlight ? "notification" : osdVisible ? "osd" : Media.playing ? "media" : "idle"

    Connections {
        target: Audio
        function onOsdRequested(kind) {
            root.showOsd(kind);
        }
    }

    Connections {
        target: Brightness
        function onOsdRequested(kind) {
            root.showOsd(kind);
        }
    }

    Connections {
        target: Notifs
        function onNotified(n) {
            root.showNotification(n);
        }
        function onRemoved(n) {
            if (root.spotlight === n)
                root.clearSpotlight();
        }
    }

    Timer {
        id: osdTimer
        interval: Config.options.osd?.timeoutMs ?? 1500
        onTriggered: root.osdVisible = false
    }

    Timer {
        id: spotlightTimer
        interval: 4500
        onTriggered: root.spotlight = null
    }
}
