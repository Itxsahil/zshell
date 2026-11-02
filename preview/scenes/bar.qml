import QtQuick
import qs.config
import qs.services
import qs.components
import qs.modules.bar
import qs.modules.dashboard
import qs.modules.osd
import qs.modules.notifications
import ZPreview

// Bar mode: bar + toasts + OSD, then the dashboard dropdown.
// Window placement here mirrors windows/BarWindow, ToastWindow and OsdWindow.
Desktop {
    id: desk

    topInset: 56

    BarContent {
        id: bar
        x: Theme.gap * 1.5
        y: Theme.gap
        width: desk.width - Theme.gap * 3
        height: implicitHeight
        onDashboardRequested: dropdown.visible = !dropdown.visible
    }

    ToastStack {
        x: desk.width - width - Theme.gap * 1.5
        y: bar.y + bar.height + Theme.gap
    }

    OsdContent {
        x: (desk.width - width) / 2
        y: desk.height - 90 - height
    }

    Item {
        id: dropdown
        visible: false
        x: (desk.width - width) / 2
        y: bar.y + bar.height + Theme.gap
        width: 460
        height: dash.implicitHeight + 40

        GlassSurface {
            anchors.fill: parent
            surface: "popup"
            radius: Theme.radius * 1.4
        }

        Dashboard {
            id: dash
            anchors.fill: parent
            anchors.margins: 20
        }
    }

    Steps {
        id: steps
        steps: [
            [300, () => Media.playing = true],
            [200, () => Notifs.push({
                        appName: "Calendar",
                        summary: "Design review in 10 minutes",
                        body: "zshell glass + island walkthrough · Room 2"
                    })],
            [500, () => Notifs.push({
                        appName: "GitHub",
                        summary: "CI passed on ccr-d770efee-mcrqjf",
                        body: "All 12 checks passed",
                        actions: [
                            {
                                identifier: "open",
                                text: "Open PR"
                            }
                        ]
                    })],
            [400, () => Audio.setVolume(0.74)],
            [700, () => ZPreview.capture("bar-mode.png")],
            [10, () => ZPreview.captureRect("bar-strip.png", 0, 0, desk.width, 60)],
            [2200, () => dropdown.visible = true],
            [600, () => ZPreview.captureRect("bar-dashboard.png", desk.width / 2 - 450, 0, 900, 760)],
            [10, () => ZPreview.finish()]
        ]
    }

    Component.onCompleted: steps.start()
}
