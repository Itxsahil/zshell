import QtQuick
import qs.config
import qs.services

Row {
    id: root

    property real dot: 9

    spacing: 6

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: e => Workspaces.scroll(e.angleDelta.y < 0 ? 1 : -1)
    }

    Repeater {
        model: Workspaces.count

        delegate: Rectangle {
            id: ws

            required property int index
            readonly property int wsId: index + 1
            readonly property bool focused: wsId === Workspaces.focusedId
            readonly property bool occupied: Workspaces.occupied[wsId] === true

            anchors.verticalCenter: parent.verticalCenter
            width: focused ? root.dot * 2.8 : root.dot
            height: root.dot
            radius: height / 2
            color: focused ? Theme.primary : occupied ? Theme.alpha(Theme.text, 0.55) : Theme.alpha(Theme.text, 0.18)

            Behavior on width {
                NumberAnimation {
                    duration: Theme.dur(260)
                    easing.type: Easing.OutBack
                    easing.overshoot: 2
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.dur(200)
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Workspaces.focus(ws.wsId)
            }
        }
    }
}
