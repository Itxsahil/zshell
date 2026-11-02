import QtQuick
import qs.config

// Track + fill, optionally draggable. Emits moved(fraction) while dragging.
Item {
    id: root

    property real value: 0
    property bool interactive: false
    property color fillColor: Theme.primary
    property real thickness: 6
    signal moved(real fraction)

    implicitHeight: Math.max(thickness, 16)

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.thickness
        radius: height / 2
        color: Theme.alpha(Theme.text, 0.14)

        Rectangle {
            width: Math.max(track.height, track.width * Math.max(0, Math.min(1, root.value)))
            height: parent.height
            radius: parent.radius
            color: root.fillColor

            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation {
                    duration: Theme.dur(160)
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        enabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        function emit(x) {
            root.moved(Math.max(0, Math.min(1, x / width)));
        }
        onPressed: e => emit(e.x)
        onPositionChanged: e => {
            if (pressed)
                emit(e.x);
        }
    }
}
