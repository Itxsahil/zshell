import QtQuick
import qs.config

// Material Symbols ligature icon: Icon { name: "volume_up" }
Text {
    property string name
    property real size: 18

    text: name
    color: Theme.text
    font.family: Theme.iconFamily
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation {
            duration: Theme.dur(200)
        }
    }
}
