import QtQuick
import qs.config
import qs.services

// One notification: icon, app, summary, body, action buttons, close.
Item {
    id: root

    property var notification: null
    property bool compact: false
    property int bodyLines: compact ? 1 : 3

    readonly property bool critical: (notification?.urgency ?? 1) === 2

    implicitHeight: Math.max(icon.height, content.implicitHeight)

    RoundedImage {
        id: icon
        width: root.compact ? 32 : 40
        height: width
        radius: width / 2
        source: Notifs.iconFor(root.notification)
        fallbackIcon: root.critical ? "warning" : "notifications"
    }

    Column {
        id: content
        anchors.left: icon.right
        anchors.leftMargin: 12
        anchors.right: close.left
        anchors.rightMargin: 4
        spacing: 2

        StyledText {
            width: parent.width
            text: root.notification?.appName ?? ""
            visible: text.length > 0 && !root.compact
            color: root.critical ? Theme.error : Theme.subtext
            font.pixelSize: Theme.fontSize - 2
            font.weight: Font.Medium
        }

        StyledText {
            width: parent.width
            text: root.notification?.summary ?? ""
            font.weight: Font.DemiBold
        }

        StyledText {
            width: parent.width
            visible: text.length > 0
            text: root.notification?.body ?? ""
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            maximumLineCount: root.bodyLines
            color: Theme.subtext
            lineHeight: 1.1
        }

        Row {
            visible: !root.compact && (root.notification?.actions?.length ?? 0) > 0
            spacing: 6
            topPadding: 6

            Repeater {
                model: root.compact ? [] : (root.notification?.actions ?? [])

                delegate: Rectangle {
                    id: action

                    required property var modelData

                    width: label.implicitWidth + 24
                    height: 28
                    radius: height / 2
                    color: actionMouse.containsMouse ? Theme.alpha(Theme.primary, 0.3) : Theme.alpha(Theme.text, 0.1)

                    StyledText {
                        id: label
                        anchors.centerIn: parent
                        text: action.modelData.text
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.invoke(root.notification, action.modelData)
                    }
                }
            }
        }
    }

    IconButton {
        id: close
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: -4
        icon: "close"
        size: 15
        iconColor: Theme.subtext
        onClicked: Notifs.dismiss(root.notification)
    }
}
