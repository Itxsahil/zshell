import QtQuick
import QtQuick.Effects
import qs.config

// Background for every shell surface. Place it first, put content on top:
//
//   Item {
//       GlassSurface { anchors.fill: parent; surface: "bar" }
//       Row { ... }
//   }
//
// The blur itself comes from Hyprland (layerrule blur on the zshell-*
// namespaces). This item draws the tint, top highlight and hairline border
// that turn a plain blur into frosted glass.
Item {
    id: root

    property string surface: "popup"      // "bar" | "island" | "popup"
    property real radius: Theme.radius
    property color tintColor: Theme.surface
    readonly property real tintOpacity: Glass.tint(surface)

    // Preview harness only: sample the blurred desktop behind this surface.
    Loader {
        anchors.fill: parent
        active: Glass.previewBackdrop !== null && Glass.enabled
        sourceComponent: previewBlur
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.alpha(root.tintColor, root.tintOpacity)

        Behavior on color {
            ColorAnimation {
                duration: Theme.dur(250)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: Glass.highlight > 0
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(1, 1, 1, Glass.highlight)
            }
            GradientStop {
                position: 0.45
                color: Qt.rgba(1, 1, 1, 0)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.dark ? Qt.rgba(1, 1, 1, Glass.borderOpacity) : Qt.rgba(0, 0, 0, Glass.borderOpacity)
    }

    Component {
        id: previewBlur

        Item {
            id: blurRoot

            property rect area

            function update() {
                const p = root.mapToItem(Glass.previewBackdrop, 0, 0);
                area = Qt.rect(p.x, p.y, root.width, root.height);
            }

            FrameAnimation {
                running: true
                onTriggered: blurRoot.update()
            }

            ShaderEffectSource {
                id: slice
                anchors.fill: parent
                sourceItem: Glass.previewBackdrop
                sourceRect: blurRoot.area
                visible: false
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
                source: slice
                maskEnabled: true
                maskSource: mask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
            }
        }
    }
}
