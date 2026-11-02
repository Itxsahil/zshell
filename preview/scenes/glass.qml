import QtQuick
import qs.config
import qs.services
import qs.modules.island
import ZPreview

// Glass off + every glass preset, same scene, so blur/tint differences show.
Desktop {
    id: desk

    topInset: 54

    IslandContent {
        id: island
        x: (desk.width - width) / 2
        y: 8
        width: 760
        height: 760
        expanded: true
    }

    readonly property var looks: ["off", "subtle", "frosted", "heavy", "clear"]
    property int i: 0

    function next() {
        if (i >= looks.length) {
            ZPreview.finish();
            return;
        }
        if (looks[i] === "off")
            Glass.setEnabled(false);
        else
            Glass.applyPreset(looks[i]);
        shot.start();
    }

    Timer {
        id: shot
        interval: 900
        onTriggered: {
            ZPreview.captureRect("glass/" + desk.looks[desk.i] + ".png", desk.width / 2 - 250, 0, 500, 640);
            desk.i++;
            desk.next();
        }
    }

    Component.onCompleted: {
        Media.playing = true;
        next();
    }
}
