import QtQuick
import qs.config
import qs.services
import qs.components

// Notification toasts for bar mode, newest at the bottom.
ListView {
    id: root

    width: 380
    height: contentHeight
    spacing: Theme.gap
    interactive: false
    model: Notifs.popups

    add: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "x"
                from: root.width
                to: 0
                duration: Theme.dur(320)
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.dur(220)
            }
        }
    }

    remove: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "x"
                to: root.width
                duration: Theme.dur(240)
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: Theme.dur(200)
            }
        }
    }

    displaced: Transition {
        NumberAnimation {
            property: "y"
            duration: Theme.dur(220)
            easing.type: Easing.OutCubic
        }
    }

    delegate: Item {
        id: toast

        required property int key
        readonly property var notification: Notifs.popupAt(key)

        width: root.width
        height: card.implicitHeight + 28

        GlassSurface {
            anchors.fill: parent
            surface: "popup"
        }

        NotificationCard {
            id: card
            anchors.fill: parent
            anchors.margins: 14
            notification: toast.notification
        }
    }
}
