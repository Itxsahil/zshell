import QtQuick
import qs.config
import qs.services

// Icon + bar + percentage for volume / mic / brightness.
Row {
    id: root

    property real barWidth: 150

    spacing: 10

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        name: Activity.osdIcon
        size: 19
        color: Activity.osdMuted ? Theme.subtext : Theme.primary
    }

    ProgressTrack {
        anchors.verticalCenter: parent.verticalCenter
        width: root.barWidth
        value: Activity.osdMuted ? 0 : Activity.osdValue
        fillColor: Activity.osdValue > 1 ? Theme.warning : Theme.primary
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        horizontalAlignment: Text.AlignRight
        text: Activity.osdMuted ? "off" : Math.round(Activity.osdValue * 100) + ""
        font.weight: Font.DemiBold
        font.features: {
            "tnum": 1
        }
    }
}
