pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Design tokens. Every colour, radius, gap, font and duration in the UI comes
// from here, so changing one value restyles the whole shell.
//
// Palettes come from either a preset (themes/<name>.json) or the dynamic
// palette matugen generates from the wallpaper (~/.local/state/zshell/colors.json).
Singleton {
    id: root

    readonly property var appearance: Config.options.appearance ?? ({})
    readonly property var themeOpts: appearance.theme ?? ({})
    readonly property bool dynamic: themeOpts.source === "dynamic"
    readonly property string presetName: themeOpts.preset ?? "catppuccin-mocha"
    readonly property string palettePath: dynamic ? Config.stateDir + "/colors.json" : Quickshell.shellDir + "/themes/" + presetName + ".json"

    // Built-in fallback so the shell never renders with missing colours.
    readonly property var fallback: ({
            name: "Fallback",
            dark: true,
            colors: {
                base: "#11111b",
                surface: "#1e1e2e",
                surfaceHigh: "#313244",
                overlay: "#45475a",
                text: "#cdd6f4",
                subtext: "#a6adc8",
                primary: "#cba6f7",
                onPrimary: "#1e1e2e",
                secondary: "#89b4fa",
                tertiary: "#f5c2e7",
                error: "#f38ba8",
                warning: "#f9e2af",
                success: "#a6e3a1"
            }
        })

    property var palette: fallback
    readonly property var c: palette.colors ?? fallback.colors

    readonly property string name: palette.name ?? presetName
    readonly property bool dark: dynamic ? themeOpts.mode !== "light" : (palette.dark ?? true)

    // Colours
    readonly property color base: c.base ?? fallback.colors.base
    readonly property color surface: c.surface ?? fallback.colors.surface
    readonly property color surfaceHigh: c.surfaceHigh ?? fallback.colors.surfaceHigh
    readonly property color overlay: c.overlay ?? fallback.colors.overlay
    readonly property color text: c.text ?? fallback.colors.text
    readonly property color subtext: c.subtext ?? fallback.colors.subtext
    readonly property color primary: c.primary ?? fallback.colors.primary
    readonly property color onPrimary: c.onPrimary ?? fallback.colors.onPrimary
    readonly property color secondary: c.secondary ?? fallback.colors.secondary
    readonly property color tertiary: c.tertiary ?? fallback.colors.tertiary
    readonly property color error: c.error ?? fallback.colors.error
    readonly property color warning: c.warning ?? fallback.colors.warning
    readonly property color success: c.success ?? fallback.colors.success

    // Shape and spacing
    readonly property real radius: appearance.radius ?? 14
    readonly property real gap: appearance.gap ?? 8
    readonly property real padding: gap * 1.5
    readonly property real barHeight: 40
    readonly property real islandHeight: 38

    // Fonts
    readonly property var fonts: appearance.fonts ?? ({})
    readonly property string fontFamily: fonts.ui ?? "Inter"
    readonly property string monoFamily: fonts.mono ?? "JetBrains Mono"
    readonly property string iconFamily: fonts.icon ?? "Material Symbols Rounded"
    readonly property real fontSize: fonts.size ?? 13

    // Motion. Use Theme.dur(ms) everywhere so speed and reduce-motion apply globally.
    readonly property bool reduceMotion: appearance.reduceMotion ?? false
    readonly property real animationSpeed: Math.max(0.1, appearance.animationSpeed ?? 1)

    function dur(ms) {
        return reduceMotion ? 0 : Math.round(ms / animationSpeed);
    }

    // Colour helpers
    function alpha(col, a) {
        return Qt.rgba(col.r, col.g, col.b, a);
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t);
    }

    // Shipped presets. Add your own by dropping a JSON file into themes/.
    readonly property var presets: ["catppuccin-mocha", "catppuccin-latte", "rose-pine", "tokyo-night", "gruvbox-dark", "nord"]

    function setPreset(preset) {
        Config.set("appearance.theme.preset", preset);
        Config.set("appearance.theme.source", "preset");
    }

    function setDynamic() {
        Config.set("appearance.theme.source", "dynamic");
    }

    function cycle() {
        const i = presets.indexOf(presetName);
        setPreset(presets[(i + 1) % presets.length]);
    }

    FileView {
        path: root.palettePath
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                if (parsed && parsed.colors)
                    root.palette = parsed;
            } catch (e) {
                console.warn("zshell: bad palette", root.palettePath, e.message);
            }
        }
        onLoadFailed: console.warn("zshell: palette not found:", root.palettePath)
    }
}
