import QtQuick
import qs.config

Rectangle {
    id: root

    property string icon
    property string label
    property string detail: ""
    property bool active: false
    signal clicked

    implicitHeight: 52
    radius: Theme.radius
    color: active ? Theme.primary : mouse.containsMouse ? Theme.alpha(Theme.surfaceHigh, 0.95) : Theme.alpha(Theme.surfaceHigh, 0.7)

    Behavior on color {
        ColorAnimation {
            duration: Theme.dur(180)
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: 20
            color: root.active ? Theme.onPrimary : Theme.text
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 30

            StyledText {
                width: parent.width
                text: root.label
                font.weight: Font.DemiBold
                color: root.active ? Theme.onPrimary : Theme.text
            }

            StyledText {
                width: parent.width
                visible: root.detail.length > 0
                text: root.detail
                font.pixelSize: Theme.fontSize - 2
                color: root.active ? Theme.alpha(Theme.onPrimary, 0.75) : Theme.subtext
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
