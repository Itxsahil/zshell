import QtQuick
import qs.config
import qs.services
import qs.modules.island
import ZPreview

// The same dashboard in every shipped theme preset.
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

    property int i: 0

    function next() {
        if (i >= Theme.presets.length) {
            ZPreview.finish();
            return;
        }
        Theme.setPreset(Theme.presets[i]);
        shot.start();
    }

    Timer {
        id: shot
        interval: 900
        onTriggered: {
            ZPreview.captureRect("themes/" + Theme.presets[desk.i] + ".png", desk.width / 2 - 250, 0, 500, 640);
            desk.i++;
            desk.next();
        }
    }

    Component.onCompleted: {
        Media.playing = true;
        next();
    }
}
