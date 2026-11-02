import QtQuick
import qs.config

// Decorative "now playing" bars. Swap for a cava-driven version later.
Row {
    id: root

    property bool playing: true
    property int bars: 4
    property real barWidth: 3
    property real maxHeight: 14
    property color color: Theme.primary

    spacing: 2
    height: maxHeight

    Repeater {
        model: root.bars

        delegate: Rectangle {
            id: bar

            required property int index
            property real level: 0.3

            anchors.bottom: parent.bottom
            width: root.barWidth
            radius: width / 2
            height: Math.max(root.barWidth, root.maxHeight * (root.playing ? level : 0.18))
            color: root.color

            Behavior on height {
                NumberAnimation {
                    duration: Theme.dur(140)
                    easing.type: Easing.OutQuad
                }
            }

            Timer {
                running: root.playing && !Theme.reduceMotion
                repeat: true
                interval: 150 + bar.index * 37
                onTriggered: bar.level = 0.25 + Math.random() * 0.75
            }
        }
    }
}
