import QtQuick
import qs.config

// A pretend app window with Hyprland-style border, so blur has detail to show.
Rectangle {
    id: root

    property bool focused: false
    property string title
    property string body
    property int fontSize: 15

    radius: 12
    color: Theme.alpha(Theme.base, 0.78)
    border.width: 2
    border.color: focused ? Theme.primary : Theme.alpha(Theme.overlay, 0.9)

    Text {
        anchors.fill: parent
        anchors.margins: 22
        text: root.body
        textFormat: Text.StyledText
        color: Theme.text
        font.family: Theme.monoFamily
        font.pixelSize: root.fontSize
        lineHeight: 1.25
    }
}
