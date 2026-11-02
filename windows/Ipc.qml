import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services

// Everything is scriptable:  qs -c zshell ipc call <target> <function> [args]
//   qs -c zshell ipc call layout toggle
//   qs -c zshell ipc call glass preset heavy
//   qs -c zshell ipc call theme set rose-pine
// List all targets with:      qs -c zshell ipc show
Scope {
    IpcHandler {
        target: "layout"

        function toggle(): void {
            Config.set("layout.mode", (Config.options.layout?.mode ?? "bar") === "bar" ? "island" : "bar");
        }
        function set(mode: string): void {
            if (mode === "bar" || mode === "island")
                Config.set("layout.mode", mode);
        }
        function get(): string {
            return Config.options.layout?.mode ?? "bar";
        }
    }

    IpcHandler {
        target: "theme"

        function set(name: string): void {
            Theme.setPreset(name);
        }
        function next(): void {
            Theme.cycle();
        }
        function dynamic(): void {
            Theme.setDynamic();
            Wallpaper.generateTheme(Wallpaper.path);
        }
        function list(): string {
            return Theme.presets.join("\n");
        }
    }

    IpcHandler {
        target: "glass"

        function toggle(): void {
            Glass.toggle();
        }
        function preset(name: string): void {
            Glass.applyPreset(name);
        }
        function blur(size: int, passes: int): void {
            Glass.setBlur("size", size);
            Glass.setBlur("passes", passes);
        }
        function tint(surface: string, value: real): void {
            Glass.setTint(surface, value);
        }
    }

    IpcHandler {
        target: "wallpaper"

        function set(path: string): void {
            Wallpaper.set(path);
        }
        function random(): void {
            Wallpaper.random();
        }
        function get(): string {
            return Wallpaper.path;
        }
    }

    IpcHandler {
        target: "volume"

        function up(): void {
            Audio.changeVolume(0.05);
        }
        function down(): void {
            Audio.changeVolume(-0.05);
        }
        function mute(): void {
            Audio.toggleMute();
        }
        function micMute(): void {
            Audio.toggleMicMute();
        }
    }

    IpcHandler {
        target: "brightness"

        function up(): void {
            Brightness.change(0.05);
        }
        function down(): void {
            Brightness.change(-0.05);
        }
    }

    IpcHandler {
        target: "notifications"

        function dnd(): void {
            Notifs.toggleDnd();
        }
        function clear(): void {
            Notifs.clearAll();
        }
    }
}
