# zshell

A Quickshell desktop shell for Hyprland on Arch: bar **or** island layout,
frosted glass with adjustable blur, theme presets + wallpaper-generated
themes, and an IPC interface for everything.

> **Status: early work in progress.** The shared UI (components/, modules/)
> renders in the preview harness. The Quickshell window glue (windows/,
> shell.qml) and the real services have not yet been run on a live
> Hyprland session.

## Layout

```
shell.qml      entry point (qs -c zshell)
config/        Config (defaults + user overrides), Theme tokens, Glass
services/      audio, media, notifications, workspaces, battery, network, ...
components/    shared widgets (plain QtQuick, no Quickshell imports)
modules/       bar, island, dashboard, osd, notification toasts
windows/       layer-shell windows that place modules on screen + IPC
themes/        palette presets (drop your own JSON here)
matugen/       template for wallpaper-generated palettes
hypr/          snippet to `source` from hyprland.conf (blur rules, keybinds)
preview/       render the real QML with mocked services (no Hyprland needed)
```

## Install (once it's ready)

```sh
git clone https://github.com/itxsahil/zshell ~/.config/quickshell/zshell
echo 'source = ~/.config/quickshell/zshell/hypr/zshell.conf' >> ~/.config/hypr/hyprland.conf
```

Dependencies: `quickshell`, `ttf-material-symbols-variable`, `inter-font`,
`ttf-jetbrains-mono`; optional `brightnessctl`, `networkmanager`, `matugen`.

Your settings live in `~/.config/zshell/config.json` and contain only what
you changed; defaults come from `defaults/config.json`.

## IPC

```sh
qs -c zshell ipc call layout toggle         # bar <-> island
qs -c zshell ipc call glass preset heavy    # subtle | frosted | heavy | clear
qs -c zshell ipc call glass blur 10 3       # blur size, passes
qs -c zshell ipc call theme set rose-pine
qs -c zshell ipc call wallpaper random
```

## Preview

```sh
pip install PySide6
xvfb-run -a -s "-screen 0 1920x1080x24" python preview/render.py   # -> docs/screenshots
python preview/render.py island --show                             # live window
```

Blur in the preview is simulated; on Hyprland it comes from the compositor.

## License

GPL-3.0
