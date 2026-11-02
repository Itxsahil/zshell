import QtQuick
import qs.config
import qs.services

// Compact now-playing: art, title, artist and the little waveform.
Row {
    id: root

    property real maxTextWidth: 180
    property bool showArtist: true

    spacing: 9

    RoundedImage {
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: 6
        source: Media.artUrl
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(root.maxTextWidth, Math.max(titleText.implicitWidth, artistText.implicitWidth))

        StyledText {
            id: titleText
            width: parent.width
            text: Media.title
            font.weight: Font.DemiBold
            font.pixelSize: Theme.fontSize - 1
        }

        StyledText {
            id: artistText
            width: parent.width
            visible: root.showArtist && text.length > 0
            text: Media.artist
            color: Theme.subtext
            font.pixelSize: Theme.fontSize - 3
        }
    }

    Waveform {
        anchors.verticalCenter: parent.verticalCenter
        playing: Media.playing
    }
}
