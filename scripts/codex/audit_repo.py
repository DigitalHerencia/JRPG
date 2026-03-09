#!/usr/bin/env python3
"""Repository audit checks for Codex workflow hardening."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GODOT_ROOT = ROOT / "march-of-legends-godot-project" / "godot"
CANONICAL_CONTENT_ROOT = GODOT_ROOT / "content"
LEGACY_CONTENT_ROOT = GODOT_ROOT / "data" / "json"

CANONICAL_JSON_FILES = {
    "characters": CANONICAL_CONTENT_ROOT / "characters.json",
    "formations": CANONICAL_CONTENT_ROOT / "formations.json",
    "skills": CANONICAL_CONTENT_ROOT / "skills.json",
    "levels": CANONICAL_CONTENT_ROOT / "levels.json",
}

LEGACY_JSON_FILES = [
    LEGACY_CONTENT_ROOT / "characters.json",
    LEGACY_CONTENT_ROOT / "formations.json",
    LEGACY_CONTENT_ROOT / "skills.json",
    LEGACY_CONTENT_ROOT / "levels.json",
]

SCENE_FILES = [
    GODOT_ROOT / "scenes" / "ui" / "MainMenu.tscn",
    GODOT_ROOT / "scenes" / "world" / "Campus.tscn",
    GODOT_ROOT / "scenes" / "band" / "FieldCommand.tscn",
    GODOT_ROOT / "scenes" / "battle" / "RhythmBattle.tscn",
    GODOT_ROOT / "scenes" / "core" / "Main.tscn",
]

REQUIRED_GITHUB_FILES = {
    "README.md": ROOT / "README.md",
    "CONTRIBUTING.md": ROOT / "CONTRIBUTING.md",
    "SECURITY.md": ROOT / "SECURITY.md",
    "CODE_OF_CONDUCT.md": ROOT / "CODE_OF_CONDUCT.md",
    ".github/CODEOWNERS": ROOT / ".github" / "CODEOWNERS",
    ".github/PULL_REQUEST_TEMPLATE.md": ROOT / ".github" / "PULL_REQUEST_TEMPLATE.md",
    ".github/ISSUE_TEMPLATE/bug_report.md": ROOT / ".github" / "ISSUE_TEMPLATE" / "bug_report.md",
    ".github/ISSUE_TEMPLATE/feature_request.md": ROOT
    / ".github"
    / "ISSUE_TEMPLATE"
    / "feature_request.md",
    ".github/ISSUE_TEMPLATE/config.yml": ROOT / ".github" / "ISSUE_TEMPLATE" / "config.yml",
    ".github/workflows/codex-audit.yml": ROOT / ".github" / "workflows" / "codex-audit.yml",
    ".github/workflows/package-artifacts.yml": ROOT
    / ".github"
    / "workflows"
    / "package-artifacts.yml",
}

REQUIRED_GITHUB_HEADINGS = {
    "CONTRIBUTING.md": "# Contributing",
    "SECURITY.md": "# Security Policy",
    "CODE_OF_CONDUCT.md": "# Code of Conduct",
}

FORBIDDEN_TRACKED_PATHS = [
    "ZIPS",
    "march-of-legends-notion-import",
    "march-of-legends-starter-package",
    "march-of-legends-godot-project/godot/.gitignore",
]

EXT_RESOURCE_PATTERN = re.compile(r'\[ext_resource\s+type="Script"\s+path="(?P<path>[^"]+)"')
AUTOLOAD_PATTERN = re.compile(r'^[A-Za-z0-9_]+="\*res://(?P<path>[^"]+)"$')
ALLOWED_LEVEL_TYPES = {"hub", "formation", "rhythm"}


def fail(message: str) -> None:
    print(f"[fail] {message}")
    raise SystemExit(1)


def _git_ls_files(paths: list[str]) -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "--", *paths],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        stderr = result.stderr.strip() or "git ls-files failed"
        fail(stderr)
    return [line for line in result.stdout.splitlines() if line.strip()]


def _load_json_list(json_file: Path) -> list[dict]:
    if not json_file.exists():
        fail(f"missing content file: {json_file.relative_to(ROOT)}")

    try:
        payload = json.loads(json_file.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"invalid json in {json_file.relative_to(ROOT)}: {exc}")

    if not isinstance(payload, list):
        fail(f"expected top-level list in {json_file.relative_to(ROOT)}")

    records: list[dict] = []
    for idx, item in enumerate(payload):
        if not isinstance(item, dict):
            fail(
                f"expected object in {json_file.relative_to(ROOT)} at index {idx}, got {type(item).__name__}"
            )
        if "id" not in item:
            fail(f"missing 'id' field in {json_file.relative_to(ROOT)} at index {idx}")
        records.append(item)
    return records


def _require_string(item: dict, field: str, path: Path, idx: int) -> str:
    value = item.get(field)
    if not isinstance(value, str) or not value.strip():
        fail(f"expected non-empty string '{field}' in {path.relative_to(ROOT)} at index {idx}")
    return value


def _require_number(item: dict, field: str, path: Path, idx: int) -> float:
    value = item.get(field)
    if not isinstance(value, (int, float)) or isinstance(value, bool):
        fail(f"expected numeric '{field}' in {path.relative_to(ROOT)} at index {idx}")
    return float(value)


def _normalize_pattern(points: list[tuple[int, int]]) -> tuple[tuple[int, int], ...]:
    ordered = sorted(points)
    anchor_x, anchor_y = ordered[0]
    return tuple((x - anchor_x, y - anchor_y) for x, y in ordered)


def _validate_pattern(
    pattern: object, path: Path, idx: int, *, require_cardinality: int | None = None
) -> tuple[tuple[int, int], ...]:
    if not isinstance(pattern, list) or not pattern:
        fail(f"expected non-empty pattern array in {path.relative_to(ROOT)} at index {idx}")

    points: list[tuple[int, int]] = []
    for point_idx, point in enumerate(pattern):
        if not isinstance(point, dict):
            fail(
                f"expected pattern point object in {path.relative_to(ROOT)} at index {idx}:{point_idx}"
            )
        x = point.get("x")
        y = point.get("y")
        if not isinstance(x, int) or not isinstance(y, int):
            fail(
                f"expected integer x/y in {path.relative_to(ROOT)} at index {idx}:{point_idx}"
            )
        points.append((x, y))

    if len(set(points)) != len(points):
        fail(f"duplicate pattern points in {path.relative_to(ROOT)} at index {idx}")
    if require_cardinality is not None and len(points) != require_cardinality:
        fail(
            f"expected pattern with {require_cardinality} points in {path.relative_to(ROOT)} at index {idx}"
        )

    return _normalize_pattern(points)


def _validate_characters(records: list[dict], path: Path) -> set[str]:
    seen_ids: set[str] = set()
    for idx, item in enumerate(records):
        character_id = _require_string(item, "id", path, idx)
        if character_id in seen_ids:
            fail(f"duplicate character id '{character_id}' in {path.relative_to(ROOT)}")
        seen_ids.add(character_id)
        for field in ("name", "section", "instrument", "role", "arc"):
            _require_string(item, field, path, idx)
    return seen_ids


def _validate_formations(records: list[dict], path: Path) -> set[str]:
    seen_ids: set[str] = set()
    seen_shapes: dict[tuple[tuple[int, int], ...], str] = {}
    for idx, item in enumerate(records):
        formation_id = _require_string(item, "id", path, idx)
        if formation_id in seen_ids:
            fail(f"duplicate formation id '{formation_id}' in {path.relative_to(ROOT)}")
        seen_ids.add(formation_id)
        for field in ("name", "effect", "description"):
            _require_string(item, field, path, idx)
        normalized_pattern = _validate_pattern(item.get("pattern"), path, idx, require_cardinality=4)
        if normalized_pattern in seen_shapes:
            fail(
                f"duplicate formation pattern '{formation_id}' duplicates '{seen_shapes[normalized_pattern]}'"
            )
        seen_shapes[normalized_pattern] = formation_id
    return seen_ids


def _validate_skills(records: list[dict], path: Path, character_ids: set[str]) -> None:
    seen_ids: set[str] = set()
    for idx, item in enumerate(records):
        skill_id = _require_string(item, "id", path, idx)
        if skill_id in seen_ids:
            fail(f"duplicate skill id '{skill_id}' in {path.relative_to(ROOT)}")
        seen_ids.add(skill_id)
        character_id = _require_string(item, "character_id", path, idx)
        if character_id not in character_ids:
            fail(
                f"unknown skill character_id '{character_id}' in {path.relative_to(ROOT)} at index {idx}"
            )
        for field in ("branch", "effect"):
            _require_string(item, field, path, idx)
        tier = item.get("tier")
        if not isinstance(tier, int) or tier < 1:
            fail(f"expected positive integer 'tier' in {path.relative_to(ROOT)} at index {idx}")


def _validate_chart_notes(notes: object, path: Path, idx: int) -> None:
    if not isinstance(notes, list) or not notes:
        fail(f"expected non-empty 'chart_notes' in {path.relative_to(ROOT)} at index {idx}")

    last_hit_time = 0.0
    for note_idx, note in enumerate(notes):
        if not isinstance(note, dict):
            fail(f"expected note object in {path.relative_to(ROOT)} at index {idx}:{note_idx}")
        lane = note.get("lane")
        if not isinstance(lane, int) or lane < 0 or lane > 3:
            fail(f"expected lane 0-3 in {path.relative_to(ROOT)} at index {idx}:{note_idx}")
        hit_time = note.get("hit_time")
        if not isinstance(hit_time, (int, float)) or isinstance(hit_time, bool) or hit_time <= 0:
            fail(
                f"expected positive numeric hit_time in {path.relative_to(ROOT)} at index {idx}:{note_idx}"
            )
        hit_time = float(hit_time)
        if hit_time <= last_hit_time:
            fail(
                f"chart_notes must be strictly ascending by hit_time in {path.relative_to(ROOT)} at index {idx}"
            )
        last_hit_time = hit_time


def _validate_levels(records: list[dict], path: Path, formation_ids: set[str]) -> None:
    seen_ids: set[str] = set()
    for idx, item in enumerate(records):
        level_id = _require_string(item, "id", path, idx)
        if level_id in seen_ids:
            fail(f"duplicate level id '{level_id}' in {path.relative_to(ROOT)}")
        seen_ids.add(level_id)

        level_type = _require_string(item, "type", path, idx)
        if level_type not in ALLOWED_LEVEL_TYPES:
            fail(
                f"unexpected level type '{level_type}' in {path.relative_to(ROOT)} at index {idx}"
            )

        for field in ("name", "boss"):
            _require_string(item, field, path, idx)

        if level_type == "formation":
            formation_id = _require_string(item, "required_formation_id", path, idx)
            if formation_id not in formation_ids:
                fail(
                    f"unknown required_formation_id '{formation_id}' in {path.relative_to(ROOT)} at index {idx}"
                )

        if level_type == "rhythm":
            rhythm = item.get("rhythm")
            if not isinstance(rhythm, dict):
                fail(f"expected rhythm object in {path.relative_to(ROOT)} at index {idx}")

            lanes = rhythm.get("lanes")
            if not isinstance(lanes, int) or lanes < 1:
                fail(f"expected positive integer lanes in {path.relative_to(ROOT)} at index {idx}")

            approach_time = _require_number(rhythm, "approach_time", path, idx)
            perfect = _require_number(rhythm, "perfect_window", path, idx)
            good = _require_number(rhythm, "good_window", path, idx)
            miss = _require_number(rhythm, "miss_window", path, idx)
            if approach_time <= 0:
                fail(f"expected positive approach_time in {path.relative_to(ROOT)} at index {idx}")
            if not (0 < perfect < good < miss):
                fail(
                    f"timing windows must satisfy perfect < good < miss in {path.relative_to(ROOT)} at index {idx}"
                )

            _validate_chart_notes(rhythm.get("chart_notes"), path, idx)
            for note in rhythm["chart_notes"]:
                if int(note["lane"]) >= lanes:
                    fail(
                        f"chart note lane exceeds lanes count in {path.relative_to(ROOT)} at index {idx}"
                    )


def check_json_files() -> None:
    canonical_payloads = {
        name: _load_json_list(path) for name, path in CANONICAL_JSON_FILES.items()
    }

    character_ids = _validate_characters(
        canonical_payloads["characters"], CANONICAL_JSON_FILES["characters"]
    )
    formation_ids = _validate_formations(
        canonical_payloads["formations"], CANONICAL_JSON_FILES["formations"]
    )
    _validate_skills(canonical_payloads["skills"], CANONICAL_JSON_FILES["skills"], character_ids)
    _validate_levels(canonical_payloads["levels"], CANONICAL_JSON_FILES["levels"], formation_ids)

    for json_file in LEGACY_JSON_FILES:
        if json_file.exists():
            _load_json_list(json_file)

    print("[ok] canonical content files and legacy JSON aliases are structurally valid")


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


def check_github_files() -> None:
    for display_name, path in REQUIRED_GITHUB_FILES.items():
        if not path.exists():
            fail(f"missing required GitHub file: {display_name}")

    for display_name, heading in REQUIRED_GITHUB_HEADINGS.items():
        path = ROOT / display_name
        content = path.read_text(encoding="utf-8")
        if heading not in content:
            fail(f"missing expected heading '{heading}' in {display_name}")

    print("[ok] GitHub community files and workflows are present")


def check_hygiene() -> None:
    tracked_forbidden_paths = _git_ls_files(FORBIDDEN_TRACKED_PATHS)
    if tracked_forbidden_paths:
        fail(
            "forbidden tracked local-only paths detected: "
            + ", ".join(tracked_forbidden_paths)
        )

    print("[ok] repository hygiene rules passed")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check", choices=["json", "scenes", "github", "hygiene"], required=True
    )
    args = parser.parse_args()

    if args.check == "json":
        check_json_files()
    elif args.check == "scenes":
        check_scenes_and_autoloads()
    elif args.check == "github":
        check_github_files()
    elif args.check == "hygiene":
        check_hygiene()

    return 0


if __name__ == "__main__":
    sys.exit(main())
