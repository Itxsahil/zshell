import QtQuick
import qs.config
import qs.services
import qs.modules.island
import ZPreview

// Island mode: each state as a still, plus an animated GIF of the sequence.
Desktop {
    id: desk

    topInset: 54

    IslandContent {
        id: island
        x: (desk.width - width) / 2
        y: 8
        width: 760
        height: 700
    }

    readonly property var crop: [desk.width / 2 - 450, 0, 900, 760]

    function shot(name) {
        ZPreview.captureRect(name, crop[0], 0, crop[2], 150);
    }

    function notify() {
        Notifs.push({
            appName: "GitHub",
            summary: "CI passed on ccr-d770efee-mcrqjf",
            body: "All 12 checks passed · island: spring-animate pill size",
            actions: [
                {
                    identifier: "open",
                    text: "Open PR"
                },
                {
                    identifier: "later",
                    text: "Later"
                }
            ]
        });
    }

    Steps {
        id: steps
        steps: [
            [900, () => desk.shot("island-1-idle.png")],
            [10, () => Media.playing = true],
            [900, () => desk.shot("island-2-media.png")],
            [10, () => Audio.setVolume(0.74)],
            [700, () => desk.shot("island-3-volume.png")],
            [1400, () => desk.notify()],
            [900, () => ZPreview.captureRect("island-4-notification.png", desk.crop[0], 0, desk.crop[2], 260)],
            [10, () => Activity.clearSpotlight()],
            [10, () => island.expanded = true],
            [1200, () => ZPreview.captureRect("island-5-dashboard.png", desk.crop[0], 0, desk.crop[2], desk.crop[3])],
            // Animated run-through
            [10, () => {
                    island.expanded = false;
                    Media.playing = false;
                }],
            [1200, () => ZPreview.startRecording("island-demo.gif", 30, desk.crop[0], 0, desk.crop[2], desk.crop[3], 0.75)],
            [800, () => Media.playing = true],
            [1500, () => Audio.setVolume(0.5)],
            [300, () => Audio.setVolume(0.58)],
            [300, () => Audio.setVolume(0.66)],
            [1800, () => desk.notify()],
            [2600, () => Activity.clearSpotlight()],
            [900, () => island.expanded = true],
            [2400, () => island.expanded = false],
            [1200, () => ZPreview.stopRecording()],
            [10, () => ZPreview.finish()]
        ]
    }

    Component.onCompleted: steps.start()
}
