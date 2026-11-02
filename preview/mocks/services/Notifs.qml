pragma Singleton
import QtQuick
import Quickshell
import qs.config

// Same API as services/Notifs.qml; push() lets scenes fake a notification.
Singleton {
    id: root

    readonly property bool dnd: Config.options.notifications?.dnd ?? false
    readonly property int maxPopups: 4
    property var history: []
    property ListModel popups: ListModel {}
    property var popupObjects: ({})
    property int nextKey: 1

    signal notified(var notification)
    signal removed(var notification)

    function popupAt(key) {
        return popupObjects[key] ?? null;
    }
    function iconFor(n) {
        return n?.image ?? "";
    }
    function setDnd(on) {
        Config.set("notifications.dnd", on);
    }
    function toggleDnd() {
        setDnd(!dnd);
    }

    function push(n) {
        n.actions = n.actions ?? [];
        n.urgency = n.urgency ?? 1;
        history = [n].concat(history);
        if (dnd && n.urgency !== 2)
            return;
        const key = nextKey++;
        popupObjects[key] = n;
        popups.append({
            key: key,
            expiresAt: 0
        });
        while (popups.count > maxPopups)
            popups.remove(0);
        notified(n);
    }

    function dismiss(n) {
        history = history.filter(h => h !== n);
        for (let i = popups.count - 1; i >= 0; i--)
            if (popupObjects[popups.get(i).key] === n)
                popups.remove(i);
        removed(n);
    }
    function invoke(n, action) {
        dismiss(n);
    }
    function clearAll() {
        for (const n of history.slice())
            dismiss(n);
    }
}
