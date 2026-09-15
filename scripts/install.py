#!/usr/bin/env python3
"""Install desktop files with backups and atomic file replacement."""

import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import uuid

REPO = Path(__file__).resolve().parents[1]
COMPONENTS = [
    "hypr", "ashell", "rofi", "swaync", "wlogout", "alacritty",
    "ml4w", "desktop-scripts", "desktop-assets",
]


def fingerprint(path):
    if path.is_symlink():
        return {"kind": "link", "value": os.readlink(path)}
    if path.is_file():
        return {"kind": "file", "value": hashlib.sha256(path.read_bytes()).hexdigest()}
    if path.exists():
        raise ValueError(f"Expected a file: {path}")
    return {"kind": "absent"}


def write_json(path, value):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n")
    temporary.replace(path)


def replace_file(destination, source=None, link=None, mode=None):
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.parent / (".dotfiles-" + uuid.uuid4().hex)
    try:
        if link is not None:
            temporary.symlink_to(link)
        else:
            shutil.copy2(source, temporary)
            if mode is not None:
                temporary.chmod(mode)
        os.replace(temporary, destination)
    finally:
        if temporary.is_symlink() or temporary.exists():
            temporary.unlink()


def checked_target(root, relative):
    relative = Path(relative)
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError("Invalid target path")
    path = root / relative
    if not path.parent.resolve().is_relative_to(root):
        raise ValueError(f"Parent directory is outside the target: {path}")
    return path


def restore(directory, apply):
    manifest = json.loads((directory / "manifest.json").read_text())
    root = Path(manifest["target"]).resolve()
    pending = []
    for item in reversed(manifest["files"]):
        path = checked_target(root, item["path"])
        current = fingerprint(path)
        if current == item["before"]:
            continue
        if current != item["after"]:
            raise ValueError(f"File changed after installation; preserve it first: {path}")
        pending.append((path, item))
    for path, item in pending:
        print("RESTORE", path)
        if not apply:
            continue
        old = item["before"]
        if old["kind"] == "absent":
            path.unlink()
        elif old["kind"] == "link":
            replace_file(path, link=old["value"])
        else:
            replace_file(path, source=directory / "files" / item["path"])
    if not apply:
        print("Preview only. Add --apply to restore these files.")


def build_plan(target, components):
    entries = []
    # Create local files before installing configuration that refers to them.
    if "hypr" in components:
        for source in sorted((REPO / "examples/hypr/local").iterdir()):
            relative = Path(".config/hypr/local") / source.name
            path = checked_target(target, relative)
            if not path.exists() and not path.is_symlink():
                entries.append((relative, source, None, 0o600))
    if "ml4w" in components:
        relative = Path(".config/ml4w-hyprland-settings/hyprctl.json")
        path = checked_target(target, relative)
        if not path.exists() and not path.is_symlink():
            entries.append((relative, REPO / "examples/ml4w/hyprctl.json", None, 0o600))
    seen = set()
    for component in components:
        base = REPO / component
        for source in sorted(base.rglob("*")):
            if source.is_dir():
                continue
            relative = source.relative_to(base)
            if relative in seen:
                raise ValueError(f"Duplicate target: {relative}")
            seen.add(relative)
            path = checked_target(target, relative)
            link = os.path.relpath(source, path.parent)
            if path.is_symlink() and os.readlink(path) == link:
                continue
            fingerprint(path)
            entries.append((relative, source, link, None))
    return entries


def install(args):
    target = args.target.expanduser().resolve()
    stow = shutil.which("stow")
    if not stow:
        candidate = Path.home() / ".local/bin/stow"
        if candidate.is_file():
            stow = str(candidate)
    if not stow:
        raise ValueError("Install GNU Stow before you run this command.")
    components = list(dict.fromkeys(args.components or COMPONENTS))
    plan = build_plan(target, components)
    for relative, source, link, mode in plan:
        print("LINK" if link is not None else "CREATE LOCAL", target / relative)
    if not args.apply:
        print(f"Preview only: {len(plan)} file changes. Add --apply to install.")
        return
    if not plan:
        print("All selected files are installed.")
        return

    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    directory = target / ".local/state/dotfiles/installs" / (stamp + "-" + uuid.uuid4().hex[:8])
    directory.mkdir(parents=True, mode=0o700)
    directory.chmod(0o700)
    manifest = {"target": str(target), "repository": str(REPO), "files": []}
    try:
        # Back up and record every target before changing any active file.
        for relative, source, link, mode in plan:
            path = checked_target(target, relative)
            before = fingerprint(path)
            if before["kind"] == "file":
                saved = directory / "files" / relative
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, saved)
            after = {"kind": "link", "value": link} if link is not None else fingerprint(source)
            manifest["files"].append({"path": str(relative), "before": before, "after": after})
        write_json(directory / "manifest.json", manifest)
        for (relative, source, link, mode), item in zip(plan, manifest["files"]):
            path = checked_target(target, relative)
            if fingerprint(path) != item["before"]:
                raise ValueError(f"File changed during installation: {path}")
            replace_file(path, source, link, mode)
        # Keep individual links so local files stay outside the repository.
        subprocess.run([
            stow, "--no-folding", "--dir", str(REPO), "--target", str(target),
            *components,
        ], check=True)
    except Exception:
        if (directory / "manifest.json").exists():
            restore(directory, True)
        raise
    print("Installation complete. Backup:", directory)
    print("No desktop process was restarted.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Apply the plan. The default is a preview.")
    parser.add_argument("--target", type=Path, default=Path.home(), help="Target home directory.")
    parser.add_argument("--components", nargs="+", choices=COMPONENTS)
    parser.add_argument("--restore", type=Path, help="Restore files from an installation backup.")
    args = parser.parse_args()
    try:
        if args.restore:
            restore(args.restore.expanduser().resolve(), args.apply)
        else:
            install(args)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print("ERROR:", error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
