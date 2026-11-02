import QtQuick
import qs.config
import qs.services

// Full player: art, track info, seekable progress and controls.
Item {
    id: root

    implicitHeight: 96

    function fmt(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    RoundedImage {
        id: art
        width: 96
        height: 96
        radius: Theme.radius - 2
        source: Media.artUrl
    }

    Column {
        anchors.left: art.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.verticalCenter: art.verticalCenter
        spacing: 4

        StyledText {
            width: parent.width
            text: Media.title
            font.pixelSize: Theme.fontSize + 2
            font.weight: Font.DemiBold
        }

        StyledText {
            width: parent.width
            text: Media.artist + (Media.album ? "  ·  " + Media.album : "")
            color: Theme.subtext
        }

        ProgressTrack {
            width: parent.width
            value: Media.progress
            thickness: 4
            interactive: true
            onMoved: f => Media.seek(f)
        }

        Item {
            width: parent.width
            height: 30

            StyledText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.fmt(Media.position) + " / " + root.fmt(Media.length)
                color: Theme.subtext
                font.pixelSize: Theme.fontSize - 2
                font.features: {
                    "tnum": 1
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "skip_previous"
                    size: 20
                    onClicked: Media.previous()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: Media.playing ? "pause" : "play_arrow"
                    size: 22
                    filled: true
                    onClicked: Media.toggle()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "skip_next"
                    size: 20
                    onClicked: Media.next()
                }
            }
        }
    }
}
