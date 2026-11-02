import QtQuick
import qs.config
import qs.services

Row {
    id: root

    // The PanelWindow this row is in (needed to place tray menus).
    property var hostWindow: null
    property real size: 16

    spacing: 8
    visible: Tray.items.length > 0

    Repeater {
        model: Tray.items

        delegate: Item {
            id: trayItem

            required property var modelData

            anchors.verticalCenter: parent.verticalCenter
            width: root.size
            height: root.size

            Image {
                anchors.fill: parent
                source: Tray.iconFor(trayItem.modelData)
                sourceSize.width: root.size * 2
                sourceSize.height: root.size * 2
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: e => {
                    if (e.button === Qt.LeftButton) {
                        Tray.activate(trayItem.modelData);
                        return;
                    }
                    const p = trayItem.mapToItem(null, 0, trayItem.height + 6);
                    Tray.openMenu(trayItem.modelData, root.hostWindow, p.x, p.y);
                }
            }
        }
    }
}
