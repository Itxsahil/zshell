pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

// zshell is the notification daemon (replaces dunst/mako).
//   history - every tracked notification, newest first
//   popups  - the ones currently shown as toasts (bar mode)
//   notified(n) - fires for every new notification (the island listens)
Singleton {
    id: root

    readonly property bool dnd: Config.options.notifications?.dnd ?? false
    readonly property int timeoutMs: Config.options.notifications?.timeoutMs ?? 5000
    readonly property int maxPopups: Config.options.notifications?.maxPopups ?? 4

    readonly property var history: {
        const list = [];
        const values = server.trackedNotifications.values;
        for (let i = values.length - 1; i >= 0; i--)
            list.push(values[i]);
        return list;
    }
    // Toasts currently on screen. A ListModel (not a JS array) so the toast
    // list can animate items in and out without rebuilding every delegate.
    property ListModel popups: ListModel {}
    property var popupObjects: ({})
    property int nextKey: 1

    function popupAt(key) {
        return popupObjects[key] ?? null;
    }

    signal notified(var notification)
    signal removed(var notification)

    function iconFor(n) {
        if (!n)
            return "";
        if (n.image)
            return n.image;
        if (!n.appIcon)
            return "";
        return n.appIcon.startsWith("/") || n.appIcon.startsWith("file:") ? n.appIcon : Quickshell.iconPath(n.appIcon, true);
    }

    function setDnd(on) {
        Config.set("notifications.dnd", on);
    }

    function toggleDnd() {
        setDnd(!dnd);
    }

    function dismiss(n) {
        n?.dismiss();
    }

    function invoke(n, action) {
        action?.invoke();
        if (n && !n.resident)
            n.dismiss();
    }

    function clearAll() {
        const values = server.trackedNotifications.values;
        const copy = [];
        for (let i = 0; i < values.length; i++)
            copy.push(values[i]);
        for (const n of copy)
            n.dismiss();
    }

    function addPopup(n, expiresAt) {
        const key = nextKey++;
        popupObjects[key] = n;
        popups.append({
            key: key,
            expiresAt: expiresAt
        });
        while (popups.count > maxPopups)
            removePopupAt(0);
    }

    function removePopupAt(i) {
        delete popupObjects[popups.get(i).key];
        popups.remove(i);
    }

    function hidePopup(n) {
        for (let i = popups.count - 1; i >= 0; i--)
            if (popupObjects[popups.get(i).key] === n)
                removePopupAt(i);
    }

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            n.closed.connect(() => {
                root.hidePopup(n);
                root.removed(n);
            });

            const critical = n.urgency === NotificationUrgency.Critical;
            if (root.dnd && !critical)
                return;

            const timeout = n.expireTimeout > 0 ? n.expireTimeout : root.timeoutMs;
            root.addPopup(n, critical ? 0 : Date.now() + timeout);
            root.notified(n);
        }
    }

    Timer {
        running: root.popups.count > 0
        interval: 250
        repeat: true
        onTriggered: {
            const now = Date.now();
            for (let i = root.popups.count - 1; i >= 0; i--) {
                const exp = root.popups.get(i).expiresAt;
                if (exp > 0 && exp <= now)
                    root.removePopupAt(i);
            }
        }
    }
}
