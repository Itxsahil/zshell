import QtQuick
import qs.config
import qs.services
import qs.components

// Volume / brightness popup for bar mode (island mode shows it in the pill).
Item {
    id: root

    readonly property bool shown: Activity.osdVisible
    readonly property bool animating: opacity > 0

    implicitWidth: osd.implicitWidth + 36
    implicitHeight: 52
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.92

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.dur(180)
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: Theme.dur(220)
            easing.type: Easing.OutBack
        }
    }

    GlassSurface {
        anchors.fill: parent
        surface: "popup"
        radius: height / 2
    }

    OsdBar {
        id: osd
        anchors.centerIn: parent
        barWidth: 180
    }
}
