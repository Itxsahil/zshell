import QtQuick
import qs.config
import qs.services
import qs.components
import qs.modules.dashboard

// Island mode: one pill that carries everything the bar would.
//
//   collapsed:  [ workspaces |  centre  | status ]
//   centre by priority: notification > osd > media > clock
//   expands for: notifications (auto) and the dashboard (click)
//
// IslandWindow (windows/) sizes this to the whole window and uses `pill`
// as the input mask, so clicks outside the pill reach the apps below.
Item {
    id: root

    readonly property alias pill: pill
    readonly property real collapsedHeight: Theme.islandHeight
    property bool expanded: false

    readonly property string mode: expanded ? "dashboard" : Activity.current
    readonly property bool showBody: mode === "dashboard" || mode === "notification"
    readonly property real bodyWidth: mode === "dashboard" ? 440 : 400

    function toggle() {
        expanded = !expanded;
    }

    Item {
        id: pill

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.showBody ? Math.max(root.bodyWidth, topRow.implicitWidth + 36) : topRow.implicitWidth + 36
        height: root.collapsedHeight + (root.showBody ? body.implicitHeight + 18 : 0)

        Behavior on width {
            enabled: !Theme.reduceMotion
            SpringAnimation {
                spring: 3.6 * Theme.animationSpeed
                damping: 0.34
                epsilon: 0.3
            }
        }
        Behavior on height {
            enabled: !Theme.reduceMotion
            SpringAnimation {
                spring: 3.6 * Theme.animationSpeed
                damping: 0.36
                epsilon: 0.3
            }
        }

        GlassSurface {
            anchors.fill: parent
            surface: "island"
            radius: root.showBody ? Theme.radius * 1.6 : root.collapsedHeight / 2

            Behavior on radius {
                NumberAnimation {
                    duration: Theme.dur(260)
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Hover pauses the notification timeout and keeps the dashboard open.
        // (A HoverHandler on the pill also sees hovers over child buttons.)
        HoverHandler {
            id: hover
            onHoveredChanged: {
                Activity.holdSpotlight(hovered && root.mode === "notification");
                if (hovered)
                    collapseTimer.stop();
                else if (root.expanded)
                    collapseTimer.restart();
            }
        }

        // Click empty pill space to open/close the dashboard; scroll = volume.
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggle()
            onWheel: e => Audio.changeVolume(e.angleDelta.y > 0 ? 0.05 : -0.05)
        }

        Item {
            id: clipper
            anchors.fill: parent
            clip: true

            Row {
                id: topRow

                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                height: root.collapsedHeight
                spacing: 18

                WorkspaceDots {
                    anchors.verticalCenter: parent.verticalCenter
                    dot: 8
                }

                // Centre slot: all variants exist, the active one fades in and
                // the slot width springs to fit it.
                Item {
                    id: centre

                    readonly property string key: Activity.current
                    readonly property Item current: key === "notification" ? notifPeek : key === "osd" ? osdSlot : key === "media" ? mediaSlot : clockSlot

                    anchors.verticalCenter: parent.verticalCenter
                    width: current.implicitWidth
                    height: root.collapsedHeight

                    Behavior on width {
                        enabled: !Theme.reduceMotion
                        SpringAnimation {
                            spring: 4 * Theme.animationSpeed
                            damping: 0.4
                            epsilon: 0.3
                        }
                    }

                    component Slot: Item {
                        required property string name
                        readonly property bool active: centre.key === name
                        anchors.centerIn: parent
                        height: parent.height
                        opacity: active ? 1 : 0
                        scale: active ? 1 : 0.85
                        visible: opacity > 0.01

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.dur(200)
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.dur(240)
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Slot {
                        id: clockSlot
                        name: "idle"
                        implicitWidth: clockRow.implicitWidth

                        Row {
                            id: clockRow
                            anchors.centerIn: parent
                            spacing: 8

                            StyledText {
                                text: Time.time
                                font.weight: Font.Bold
                                font.pixelSize: Theme.fontSize + 1
                                font.features: {
                                    "tnum": 1
                                }
                            }

                            StyledText {
                                text: Time.date
                                color: Theme.subtext
                            }
                        }
                    }

                    Slot {
                        id: mediaSlot
                        name: "media"
                        implicitWidth: mediaMini.implicitWidth

                        MediaMini {
                            id: mediaMini
                            anchors.centerIn: parent
                            showArtist: false
                            maxTextWidth: 170
                        }
                    }

                    Slot {
                        id: osdSlot
                        name: "osd"
                        implicitWidth: osdBar.implicitWidth

                        OsdBar {
                            id: osdBar
                            anchors.centerIn: parent
                            barWidth: 160
                        }
                    }

                    Slot {
                        id: notifPeek
                        name: "notification"
                        implicitWidth: peekRow.implicitWidth

                        Row {
                            id: peekRow
                            anchors.centerIn: parent
                            spacing: 8

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "notifications_active"
                                size: 17
                                color: Theme.primary
                            }

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.min(implicitWidth, 160)
                                text: Activity.spotlight?.appName || "Notification"
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                StatusIcons {
                    anchors.verticalCenter: parent.verticalCenter
                    size: 16
                    showBatteryText: false
                }
            }

            // Expanded body
            Item {
                id: body

                anchors.top: topRow.bottom
                anchors.topMargin: 4
                x: 18
                width: pill.width - 36
                implicitHeight: root.mode === "dashboard" ? dashboard.implicitHeight : root.mode === "notification" ? card.implicitHeight : 0
                opacity: root.showBody ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.dur(root.showBody ? 260 : 120)
                    }
                }

                Dashboard {
                    id: dashboard
                    width: root.bodyWidth - 36
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.mode === "dashboard"
                }

                NotificationCard {
                    id: card
                    width: parent.width
                    visible: root.mode === "notification"
                    notification: Activity.spotlight
                }
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: 700
        onTriggered: root.expanded = false
    }
}
