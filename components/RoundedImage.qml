import QtQuick
import QtQuick.Effects
import qs.config

Item {
    id: root

    property string source
    property real radius: 8
    property string fallbackIcon: "music_note"
    readonly property bool hasImage: img.status === Image.Ready

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        mipmap: true
        visible: false
        sourceSize.width: Math.max(64, root.width * 2)
        sourceSize.height: Math.max(64, root.height * 2)
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: root.radius
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        visible: root.hasImage
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: !root.hasImage
        color: Theme.surfaceHigh

        Icon {
            anchors.centerIn: parent
            name: root.fallbackIcon
            size: parent.height * 0.55
            color: Theme.subtext
        }
    }
}
