import QtQuick
import qs.config
import qs.services

// Network, bluetooth, volume and battery. Scroll on it to change volume,
// click the speaker to mute.
Row {
    id: root

    property real size: 17
    property bool showBatteryText: true

    spacing: 10

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: e => Audio.changeVolume(e.angleDelta.y > 0 ? 0.05 : -0.05)
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        size: root.size
        color: Network.connected ? Theme.text : Theme.subtext
        name: {
            if (Network.type === "ethernet")
                return "settings_ethernet";
            if (Network.type === "wifi")
                return Network.strength > 66 ? "signal_wifi_4_bar" : Network.strength > 33 ? "network_wifi_3_bar" : "network_wifi_1_bar";
            return "signal_wifi_off";
        }
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        visible: Bluetooth.available
        size: root.size
        color: Bluetooth.enabled ? Theme.text : Theme.subtext
        name: !Bluetooth.enabled ? "bluetooth_disabled" : Bluetooth.connected.length > 0 ? "bluetooth_connected" : "bluetooth"
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        size: root.size
        color: Audio.muted ? Theme.subtext : Theme.text
        name: Audio.muted || Audio.volume <= 0 ? "volume_off" : Audio.volume > 0.5 ? "volume_up" : "volume_down"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.toggleMute()
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        visible: Battery.available
        spacing: 3

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: root.size
            color: Battery.percent < 0.15 && !Battery.charging ? Theme.error : Battery.charging ? Theme.success : Theme.text
            name: {
                if (Battery.charging)
                    return "battery_charging_full";
                if (Battery.percent < 0.15)
                    return "battery_alert";
                const bars = Math.min(6, Math.floor(Battery.percent * 7));
                return Battery.percent > 0.95 ? "battery_full" : "battery_" + bars + "_bar";
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showBatteryText
            text: Math.round(Battery.percent * 100) + "%"
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.Medium
        }
    }
}
