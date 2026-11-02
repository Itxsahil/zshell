import QtQuick
import qs.config

Text {
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation {
            duration: Theme.dur(200)
        }
    }
}
