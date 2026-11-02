import QtQuick
import qs.config

Item {
    id: root

    property string icon
    property real size: 18
    property bool active: false
    property bool filled: false        // solid primary circle (e.g. play button)
    property color iconColor: active || filled ? Theme.onPrimary : Theme.text
    signal clicked
    signal rightClicked

    implicitWidth: size + 14
    implicitHeight: size + 14

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.active || root.filled ? Theme.primary : mouse.containsMouse ? Theme.alpha(Theme.text, 0.1) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.dur(150)
            }
        }
    }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.size
        color: root.iconColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => e.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
