import QtQuick
import qs.config
import qs.services
import qs.components

// Control centre. Bar mode shows it in a dropdown, island mode inside the
// expanded pill; same component either way.
Column {
    id: root

    spacing: 14

    // Header: time, date, battery
    Item {
        width: parent.width
        height: 50

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: Time.time
                font.pixelSize: 30
                font.weight: Font.Bold
                font.features: {
                    "tnum": 1
                }
            }

            StyledText {
                text: Time.longDate
                color: Theme.subtext
            }
        }

        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            StatusIcons {
                anchors.right: parent.right
            }

            StyledText {
                anchors.right: parent.right
                text: Network.connected ? Network.name : "Offline"
                color: Theme.subtext
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }

    MediaCard {
        width: parent.width
        visible: Media.hasPlayer
    }

    Column {
        width: parent.width
        spacing: 4

        SliderRow {
            width: parent.width
            icon: Audio.muted ? "volume_off" : "volume_up"
            value: Audio.volume
            muted: Audio.muted
            onMoved: f => Audio.setVolume(f)
            onIconClicked: Audio.toggleMute()
        }

        SliderRow {
            width: parent.width
            visible: Brightness.available
            icon: "brightness_medium"
            value: Brightness.value
            onMoved: f => Brightness.set(f)
        }
    }

    Grid {
        id: toggles

        width: parent.width
        columns: 2
        columnSpacing: 8
        rowSpacing: 8

        readonly property real cell: (width - columnSpacing) / 2

        QuickToggle {
            width: toggles.cell
            icon: "blur_on"
            label: "Glass"
            detail: Glass.enabled ? Glass.preset : "Solid"
            active: Glass.enabled
            onClicked: Glass.toggle()
        }

        QuickToggle {
            width: toggles.cell
            icon: Notifs.dnd ? "notifications_off" : "notifications"
            label: "Do not disturb"
            detail: Notifs.dnd ? "On" : "Off"
            active: Notifs.dnd
            onClicked: Notifs.toggleDnd()
        }

        QuickToggle {
            width: toggles.cell
            icon: Config.options.layout.mode === "island" ? "toll" : "web_asset"
            label: "Layout"
            detail: Config.options.layout.mode === "island" ? "Island" : "Bar"
            onClicked: Config.set("layout.mode", Config.options.layout.mode === "island" ? "bar" : "island")
        }

        QuickToggle {
            width: toggles.cell
            icon: "palette"
            label: "Theme"
            detail: Theme.dynamic ? "From wallpaper" : Theme.name
            onClicked: Theme.cycle()
        }
    }

    // Notification history
    Item {
        width: parent.width
        height: 22

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Notifications"
            font.weight: Font.DemiBold
        }

        StyledText {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: Notifs.history.length > 0
            text: "Clear all"
            color: Theme.primary
            font.pixelSize: Theme.fontSize - 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifs.clearAll()
            }
        }
    }

    StyledText {
        width: parent.width
        visible: Notifs.history.length === 0
        text: "You're all caught up"
        color: Theme.subtext
        horizontalAlignment: Text.AlignHCenter
        bottomPadding: 6
    }

    Repeater {
        model: Notifs.history.slice(0, 3)

        delegate: Rectangle {
            required property var modelData

            width: root.width
            height: card.implicitHeight + 20
            radius: Theme.radius - 2
            color: Theme.alpha(Theme.surfaceHigh, 0.6)

            NotificationCard {
                id: card
                anchors.fill: parent
                anchors.margins: 10
                compact: true
                notification: parent.modelData
            }
        }
    }
}
