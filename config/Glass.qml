pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Frosted glass = Hyprland blur (behind the surface) + a translucent tint and a
// thin highlight border (drawn by GlassSurface).
//
// Hyprland's blur strength is global, so the blur.* values change blur for
// every blurred surface. Per-surface "frost" is the tint opacity.
Singleton {
    id: root

    readonly property var opts: Config.options.appearance?.glass ?? ({})
    readonly property bool enabled: opts.enabled ?? true
    readonly property var blur: opts.blur ?? ({})
    readonly property string preset: opts.preset ?? "custom"

    // Let users who manage blur in hyprland.conf opt out of zshell touching it.
    readonly property bool manageHyprland: opts.manageHyprland ?? true

    readonly property real borderOpacity: enabled ? (opts.border ?? 0.12) : 0.06
    readonly property real highlight: enabled ? (opts.highlight ?? 0.06) : 0

    // Opacity of the tint for a surface ("bar", "island", "popup").
    // Glass off = fully opaque, so the blur behind it is simply not visible.
    function tint(surface) {
        if (!enabled)
            return 1.0;
        const t = opts.tint ?? {};
        return t[surface] ?? 0.65;
    }

    readonly property var presets: ({
            subtle: {
                blur: {
                    size: 4,
                    passes: 2,
                    noise: 0.01,
                    contrast: 0.95,
                    brightness: 0.95,
                    vibrancy: 0.1
                },
                tint: {
                    bar: 0.75,
                    island: 0.8,
                    popup: 0.85
                }
            },
            frosted: {
                blur: {
                    size: 8,
                    passes: 3,
                    noise: 0.02,
                    contrast: 0.9,
                    brightness: 0.85,
                    vibrancy: 0.2
                },
                tint: {
                    bar: 0.55,
                    island: 0.62,
                    popup: 0.7
                }
            },
            heavy: {
                blur: {
                    size: 12,
                    passes: 4,
                    noise: 0.04,
                    contrast: 0.85,
                    brightness: 0.8,
                    vibrancy: 0.3
                },
                tint: {
                    bar: 0.35,
                    island: 0.42,
                    popup: 0.5
                }
            },
            clear: {
                blur: {
                    size: 2,
                    passes: 1,
                    noise: 0.0,
                    contrast: 1.0,
                    brightness: 1.0,
                    vibrancy: 0.0
                },
                tint: {
                    bar: 0.3,
                    island: 0.35,
                    popup: 0.45
                }
            }
        })

    function setEnabled(on) {
        Config.set("appearance.glass.enabled", on);
    }

    function toggle() {
        setEnabled(!enabled);
    }

    function applyPreset(name) {
        const p = presets[name];
        if (!p)
            return;
        Config.set("appearance.glass.blur", p.blur);
        Config.set("appearance.glass.tint", p.tint);
        Config.set("appearance.glass.preset", name);
        if (!enabled)
            setEnabled(true);
    }

    // key: size | passes | noise | contrast | brightness | vibrancy
    function setBlur(key, value) {
        Config.set("appearance.glass.blur." + key, value);
        Config.set("appearance.glass.preset", "custom");
    }

    function setTint(surface, value) {
        Config.set("appearance.glass.tint." + surface, Math.max(0, Math.min(1, value)));
        Config.set("appearance.glass.preset", "custom");
    }

    // Preview harness only: the item to sample as "what's behind the glass".
    // Always null in the real shell, where Hyprland does the blurring.
    property Item previewBackdrop: null

    // ---- Push blur values to Hyprland ------------------------------------

    function hyprctlBatch() {
        const b = blur;
        const kw = (k, v) => `keyword decoration:blur:${k} ${v}`;
        return [kw("enabled", 1), kw("size", Math.round(b.size ?? 8)), kw("passes", Math.round(b.passes ?? 3)), kw("noise", b.noise ?? 0.02), kw("contrast", b.contrast ?? 0.9), kw("brightness", b.brightness ?? 0.85), kw("vibrancy", b.vibrancy ?? 0.2)].join(" ; ");
    }

    function applyToHyprland() {
        if (!manageHyprland)
            return;
        hyprctl.command = ["hyprctl", "--batch", hyprctlBatch()];
        hyprctl.running = true;
    }

    // Debounce so dragging a slider doesn't spawn a hyprctl per pixel.
    onBlurChanged: applyTimer.restart()
    Component.onCompleted: applyTimer.restart()

    Timer {
        id: applyTimer
        interval: 120
        onTriggered: root.applyToHyprland()
    }

    Process {
        id: hyprctl
    }
}
