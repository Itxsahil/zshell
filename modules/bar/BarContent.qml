import QtQuick
import qs.config
import qs.services
import qs.components

// The bar itself. Pure QtQuick: BarWindow (windows/) puts it on screen.
//   left   - logo, workspaces, focused window title
//   centre - clock (click: dashboard)
//   right  - now playing, tray, status icons, notifications
Item {
    id: root

    property var hostWindow: null
    property bool floating: Config.options.layout?.floating ?? true
    signal dashboardRequested

    implicitHeight: Theme.barHeight

    GlassSurface {
        anchors.fill: parent
        surface: "bar"
        radius: root.floating ? Theme.radius : 0
    }

    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            radius: 13
            color: Theme.primary

            StyledText {
                anchors.centerIn: parent
                text: "z"
                color: Theme.onPrimary
                font.pixelSize: 16
                font.weight: Font.Black
                bottomPadding: 2
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dashboardRequested()
            }
        }

        WorkspaceDots {
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, root.width / 2 - left.x - 260)
            visible: text.length > 0 && width > 40
            text: Workspaces.activeTitle
            color: Theme.subtext
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.time
            font.weight: Font.Bold
            font.pixelSize: Theme.fontSize + 1
            font.features: {
                "tnum": 1
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 4
            height: 4
            radius: 2
            color: Theme.subtext
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.date
            color: Theme.subtext
        }
    }

    MouseArea {
        anchors.centerIn: parent
        width: 200
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: root.dashboardRequested()
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        MediaMini {
            anchors.verticalCenter: parent.verticalCenter
            visible: Media.hasPlayer
            showArtist: false
            maxTextWidth: 160
        }

        TrayRow {
            anchors.verticalCenter: parent.verticalCenter
            hostWindow: root.hostWindow
        }

        StatusIcons {
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: bell.width
            height: bell.height

            IconButton {
                id: bell
                icon: Notifs.dnd ? "notifications_off" : Notifs.history.length > 0 ? "notifications_active" : "notifications"
                size: 17
                onClicked: root.dashboardRequested()
            }

            Rectangle {
                visible: Notifs.history.length > 0 && !Notifs.dnd
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 3
                width: 8
                height: 8
                radius: 4
                color: Theme.error
            }
        }
    }
}
