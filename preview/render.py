#!/usr/bin/env python3
"""Render zshell's real QML outside Quickshell, with mocked system services.

The shared parts of zshell (config/, components/, modules/, services/Activity)
are loaded as-is. Quickshell-only pieces are swapped for the stand-ins in
preview/mocks: the services report fixed demo data, and the Quickshell /
Quickshell.Io modules provide just enough API for Config/Theme/Glass.

Hyprland's blur is simulated: each scene blurs its fake desktop with the
current glass settings and GlassSurface samples it (Glass.previewBackdrop).

    pip install PySide6
    python preview/render.py                 # every scene -> docs/screenshots
    python preview/render.py island --show   # open a live window instead

Without a display, run it under `xvfb-run -a -s "-screen 0 1920x1080x24"`.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from PySide6.QtCore import Property, QObject, QRect, QTimer, QUrl, Slot
from PySide6.QtGui import QGuiApplication, QImage
from PySide6.QtQml import qmlRegisterSingletonInstance
from PySide6.QtQuick import QQuickView

ROOT = Path(__file__).resolve().parent.parent
PREVIEW = ROOT / "preview"
SCENES = PREVIEW / "scenes"
SKIP_DIRS = {"preview", "windows", ".git", "docs"}

# Overrides layered on top of defaults/config.json for every preview run.
PREVIEW_CONFIG = {"appearance": {"fonts": {"icon": "Material Icons"}}}


def qml_dirs():
    """Yield (relative dir, path) for every source dir that holds .qml files."""
    for path in sorted(ROOT.rglob("*.qml")):
        rel = path.parent.relative_to(ROOT)
        if not rel.parts or rel.parts[0] in SKIP_DIRS:
            continue
        yield rel, path


def pretty(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def write_qmldir(directory: Path, module: str) -> None:
    lines = [f"module {module}"]
    for qml in sorted(directory.glob("*.qml")):
        is_singleton = "pragma Singleton" in qml.read_text()
        lines.append(f"{'singleton ' if is_singleton else ''}{qml.stem} 1.0 {qml.name}")
    (directory / "qmldir").write_text("\n".join(lines) + "\n")


def build_import_tree(tmp: Path) -> Path:
    """Mirror the repo as `qs.*` modules, with services replaced by mocks."""
    qs = tmp / "qs"
    mocks = PREVIEW / "mocks" / "services"
    for rel, path in qml_dirs():
        target = qs / rel
        target.mkdir(parents=True, exist_ok=True)
        source = path
        if rel.parts[0] == "services":
            mock = mocks / path.name
            if mock.exists():
                source = mock
            elif path.name != "Activity.qml":
                continue  # real service needs Quickshell; no mock -> skip
        shutil.copy(source, target / path.name)
    for directory in {p for p in qs.rglob("*") if p.is_dir()}:
        if any(directory.glob("*.qml")):
            rel = directory.relative_to(tmp)
            write_qmldir(directory, ".".join(rel.parts))
    return tmp


class Host(QObject):
    """Exposed to QML as the ZPreview singleton."""

    def __init__(self, env: dict[str, str], out_dir: Path):
        super().__init__()
        self._env = env
        self.out_dir = out_dir
        self.view: QQuickView | None = None
        self._frames: list[tuple[float, QImage]] = []
        self._rec_rect: QRect | None = None
        self._rec_name = ""
        self._rec_scale = 1.0
        self._rec_timer = QTimer()
        self._rec_timer.timeout.connect(self._grab_frame)
        self.on_finish = None

    @Property(str, constant=True)
    def shellDir(self) -> str:  # noqa: N802 (QML naming)
        return str(ROOT)

    @Slot(str, result=str)
    def env(self, name: str) -> str:
        return self._env.get(name, "")

    @Slot(str, result=bool)
    def exists(self, path: str) -> bool:
        return Path(path).is_file()

    @Slot(str, result=str)
    def readFile(self, path: str) -> str:  # noqa: N802
        try:
            return Path(path).read_text()
        except OSError:
            return ""

    @Slot(str)
    def log(self, message: str) -> None:
        print(f"  {message}")

    def _grab(self, rect: QRect | None = None) -> QImage:
        image = self.view.grabWindow()
        return image.copy(rect) if rect else image

    @Slot(str)
    def capture(self, name: str) -> None:
        self._save(self._grab(), name)

    @Slot(str, int, int, int, int)
    def captureRect(self, name: str, x: int, y: int, w: int, h: int) -> None:  # noqa: N802
        self._save(self._grab(QRect(x, y, w, h)), name)

    def _save(self, image: QImage, name: str) -> None:
        path = self.out_dir / name
        path.parent.mkdir(parents=True, exist_ok=True)
        image.save(str(path))
        print(f"  saved {pretty(path)}")

    @Slot(str, int, int, int, int, int, float)
    def startRecording(self, name, fps, x, y, w, h, scale):  # noqa: N802
        self._frames = []
        self._rec_name = name
        self._rec_rect = QRect(x, y, w, h)
        self._rec_scale = scale
        self._rec_timer.start(int(1000 / fps))

    def _grab_frame(self) -> None:
        self._frames.append((time.monotonic(), self._grab(self._rec_rect)))

    @Slot()
    def stopRecording(self) -> None:  # noqa: N802
        self._rec_timer.stop()
        frames, self._frames = self._frames, []
        if len(frames) < 2:
            return
        work = Path(tempfile.mkdtemp(prefix="zshell-frames-"))
        concat = []
        for i, (stamp, image) in enumerate(frames):
            file = work / f"{i:05d}.png"
            image.save(str(file))
            nxt = frames[i + 1][0] if i + 1 < len(frames) else stamp + 0.05
            concat += [f"file '{file}'", f"duration {max(0.02, nxt - stamp):.3f}"]
        concat.append(f"file '{work / f'{len(frames) - 1:05d}.png'}'")
        (work / "list.txt").write_text("\n".join(concat) + "\n")
        out = self.out_dir / self._rec_name
        width = int(self._rec_rect.width() * self._rec_scale)
        filters = (
            f"fps=25,scale={width}:-1:flags=lanczos,split[a][b];"
            "[a]palettegen=max_colors=200:stats_mode=diff[p];"
            "[b][p]paletteuse=dither=sierra2_4a:diff_mode=rectangle"
        )
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-f", "concat", "-safe", "0",
             "-i", str(work / "list.txt"), "-filter_complex", filters, "-loop", "0", str(out)],
            check=True,
        )
        shutil.rmtree(work, ignore_errors=True)
        print(f"  saved {pretty(out)} ({len(frames)} frames)")

    @Slot()
    def finish(self) -> None:
        if self.on_finish:
            self.on_finish()


def main() -> int:
    scenes = sorted(p.stem for p in SCENES.glob("*.qml") if p.stem[0].islower())
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("scenes", nargs="*", default=scenes, help=f"scenes to render (default: all of {', '.join(scenes)})")
    parser.add_argument("--out", type=Path, default=ROOT / "docs" / "screenshots")
    parser.add_argument("--show", action="store_true", help="keep the window open (needs a display)")
    args = parser.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="zshell-preview-"))
    build_import_tree(tmp)
    config_home = tmp / "config"
    (config_home / "zshell").mkdir(parents=True)
    (config_home / "zshell" / "config.json").write_text(json.dumps(PREVIEW_CONFIG))
    env = {
        "HOME": str(tmp),
        "XDG_CONFIG_HOME": str(config_home),
        "XDG_STATE_HOME": str(tmp / "state"),
    }

    app = QGuiApplication(sys.argv[:1])
    host = Host(env, args.out)
    qmlRegisterSingletonInstance(Host, "ZPreview", 1, 0, "ZPreview", host)

    failures = 0
    for scene in args.scenes:
        print(f"scene: {scene}")
        view = QQuickView()
        view.setResizeMode(QQuickView.ResizeMode.SizeViewToRootObject)
        view.engine().addImportPath(str(tmp))
        view.engine().addImportPath(str(PREVIEW / "mocks"))
        view.engine().warnings.connect(lambda warnings: [print("  warning:", w.toString()) for w in warnings])
        host.view = view
        view.setSource(QUrl.fromLocalFile(str(SCENES / f"{scene}.qml")))
        if view.status() == QQuickView.Status.Error:
            for error in view.errors():
                print("  error:", error.toString())
            failures += 1
            continue
        view.show()
        if args.show:
            app.exec()
            continue
        done = {"flag": False}
        host.on_finish = lambda: done.update(flag=True)
        deadline = time.monotonic() + 120
        while not done["flag"] and time.monotonic() < deadline:
            app.processEvents()
            time.sleep(0.002)
        if not done["flag"]:
            print("  timed out")
            failures += 1
        view.close()
        view.deleteLater()
        app.processEvents()

    shutil.rmtree(tmp, ignore_errors=True)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
