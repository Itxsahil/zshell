import QtQuick

// Tiny script runner for scenes:  steps: [[waitMs, fn], ...]
Item {
    id: root

    property var steps: []
    property int index: 0

    function start() {
        index = 0;
        schedule();
    }

    function schedule() {
        if (index >= steps.length)
            return;
        timer.interval = Math.max(1, steps[index][0]);
        timer.start();
    }

    Timer {
        id: timer
        onTriggered: {
            const fn = root.steps[root.index][1];
            root.index++;
            fn();
            root.schedule();
        }
    }
}
