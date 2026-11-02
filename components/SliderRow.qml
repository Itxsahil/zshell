import QtQuick
import qs.config

// Interactive setting slider: [icon] [====|-----] [42]
Row {
    id: root

    property string icon
    property real value: 0
    property bool muted: false
    property string suffix: ""
    property int decimals: 0
    property real displayScale: 100
    signal moved(real fraction)
    signal iconClicked

    spacing: 10

    IconButton {
        anchors.verticalCenter: parent.verticalCenter
        icon: root.icon
        size: 18
        iconColor: root.muted ? Theme.subtext : Theme.text
        onClicked: root.iconClicked()
    }

    ProgressTrack {
        anchors.verticalCenter: parent.verticalCenter
        width: root.width - 32 - 44 - root.spacing * 2
        value: root.muted ? 0 : root.value
        thickness: 8
        interactive: true
        onMoved: f => root.moved(f)
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        horizontalAlignment: Text.AlignRight
        text: (root.value * root.displayScale).toFixed(root.decimals) + root.suffix
        color: Theme.subtext
        font.features: {
            "tnum": 1
        }
    }
}
