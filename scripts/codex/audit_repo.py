#!/usr/bin/env python3
"""Repository audit checks for Codex workflow hardening."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GODOT_ROOT = ROOT / "march-of-legends-godot-project" / "godot"

JSON_FILES = [
    GODOT_ROOT / "data" / "json" / "characters.json",
    GODOT_ROOT / "data" / "json" / "formations.json",
    GODOT_ROOT / "data" / "json" / "skills.json",
    GODOT_ROOT / "data" / "json" / "levels.json",
]

SCENE_FILES = [
    GODOT_ROOT / "scenes" / "ui" / "MainMenu.tscn",
    GODOT_ROOT / "scenes" / "world" / "Campus.tscn",
    GODOT_ROOT / "scenes" / "band" / "FieldCommand.tscn",
    GODOT_ROOT / "scenes" / "battle" / "RhythmBattle.tscn",
    GODOT_ROOT / "scenes" / "core" / "Main.tscn",
]

EXT_RESOURCE_PATTERN = re.compile(r'\[ext_resource\s+type="Script"\s+path="(?P<path>[^"]+)"')
AUTOLOAD_PATTERN = re.compile(r'^[A-Za-z0-9_]+="\*res://(?P<path>[^"]+)"$')


def fail(message: str) -> None:
    print(f"[fail] {message}")
    raise SystemExit(1)


def check_json_files() -> None:
    for json_file in JSON_FILES:
        if not json_file.exists():
            fail(f"missing content file: {json_file.relative_to(ROOT)}")

        try:
            payload = json.loads(json_file.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            fail(f"invalid json in {json_file.relative_to(ROOT)}: {exc}")

        if not isinstance(payload, list):
            fail(f"expected top-level list in {json_file.relative_to(ROOT)}")

        for idx, item in enumerate(payload):
            if not isinstance(item, dict):
                fail(
                    f"expected object in {json_file.relative_to(ROOT)} at index {idx}, got {type(item).__name__}"
                )
            if "id" not in item:
                fail(f"missing 'id' field in {json_file.relative_to(ROOT)} at index {idx}")

    print("[ok] JSON content files are present and structurally valid")


def _resolve_res_path(res_path: str) -> Path:
    if not res_path.startswith("res://"):
        fail(f"unexpected resource path format: {res_path}")
    return GODOT_ROOT / res_path.removeprefix("res://")


def check_scenes_and_autoloads() -> None:
    project_file = GODOT_ROOT / "project.godot"
    if not project_file.exists():
        fail("missing godot/project.godot")

    in_autoload_section = False
    autoload_paths: list[Path] = []

    for line in project_file.read_text(encoding="utf-8").splitlines():
        normalized = line.strip()
        if normalized == "[autoload]":
            in_autoload_section = True
            continue
        if in_autoload_section and normalized.startswith("[") and normalized != "[autoload]":
            in_autoload_section = False
        if in_autoload_section and normalized:
            match = AUTOLOAD_PATTERN.match(normalized)
            if match:
                autoload_paths.append(GODOT_ROOT / match.group("path"))

    if not autoload_paths:
        fail("no autoload entries discovered in project.godot")

    for path in autoload_paths:
        if not path.exists():
            fail(f"autoload script not found: {path.relative_to(ROOT)}")

    for scene_file in SCENE_FILES:
        if not scene_file.exists():
            fail(f"scene missing: {scene_file.relative_to(ROOT)}")

        content = scene_file.read_text(encoding="utf-8")
        script_paths = [m.group("path") for m in EXT_RESOURCE_PATTERN.finditer(content)]
        for script_path in script_paths:
            script_file = _resolve_res_path(script_path)
            if not script_file.exists():
                fail(
                    f"scene references missing script: {scene_file.relative_to(ROOT)} -> {script_path}"
                )

    print("[ok] scene script references and autoload targets are valid")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", choices=["json", "scenes"], required=True)
    args = parser.parse_args()

    if args.check == "json":
        check_json_files()
    elif args.check == "scenes":
        check_scenes_and_autoloads()

    return 0


if __name__ == "__main__":
    sys.exit(main())
