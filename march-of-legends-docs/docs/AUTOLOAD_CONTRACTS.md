# Autoload Contracts

This document is the stability contract for the Godot autoload layer. Treat these signals, method names, and content expectations as public interfaces for the vertical slice.

## GameState

Purpose: store run-state, expose observable mutations, and persist save slots.

- Signals:
  - `state_changed(changed_keys: Array[String])`
- Public methods:
  - `reset_to_defaults()`
  - `set_flag(flag_name, value := true)`
  - `has_flag(flag_name)`
  - `set_stat(stat_name, value)`
  - `add_stat(stat_name, delta)`
  - `add_hype(amount)`
  - `advance_week()`
  - `set_current_scene_by_key(scene_key, scene_path := "")`
  - `set_current_scene_path(scene_path, scene_key := "")`
  - `get_current_scene_key()`
  - `get_current_scene_path()`
  - `to_dict()`
  - `from_dict(data)`
  - `save_to_slot(slot_name := "save_01")`
  - `load_from_slot(slot_name := "save_01")`
- Behavioral expectations:
  - emit `state_changed` only when a value actually changes
  - keep `current_scene_key` and `current_scene_path` in sync with successful routed scene transitions
  - preserve save schema keys: `current_scene_key`, `current_scene_path`, `player_name`, `party`, `flags`, `stats`

## SceneRouter

Purpose: own scene changes, route-key lookup, transition lifecycle, and route-level notifications.

- Signals:
  - `route_changed(route_key: String)`
  - `scene_change_started(previous_scene_path: String, next_scene_path: String)`
  - `scene_change_finished(previous_scene_path: String, next_scene_path: String)`
- Public methods:
  - `change_scene(path)`
  - `change_scene_key(route_key)`
  - `goto(route_key)` as backward-compatible alias
  - `push_scene(path)`
- Behavioral expectations:
  - reject empty or unknown scene targets without changing state
  - serialize transitions with the internal lock so re-entrant scene changes are ignored
  - update `GameState` after a successful scene swap, then emit `route_changed` when the path maps to a known route key
  - preserve `goto()` until all call sites and external tooling no longer rely on it

## AudioManager

Purpose: resolve keyed audio assets and react to routed scene changes.

- Public methods:
  - `play_music(name, fade_in_sec := 0.5)`
  - `stop_music(fade_out_sec := 0.5)`
  - `play_sound(name)`
  - `set_music_volume_db(volume_db)`
  - `set_sfx_volume_db(volume_db)`
- Behavioral expectations:
  - subscribe to `SceneRouter.route_changed`
  - treat `music_stream_paths`, `sfx_stream_paths`, and `route_music_keys` as editor-configured data, not hardcoded runtime state
  - warn instead of crashing when keys, buses, or resources are missing

## ContentDB

Purpose: load gameplay data into memory and normalize content access for runtime systems.

- Public methods:
  - `load_characters()`
  - `load_formations()`
  - `load_skills()`
  - `load_levels()`
  - `get_character(id)`
  - `get_skill(id)`
  - `get_level(id)`
  - `get_formation_by_id(id)`
  - `get_formation(id)` compatibility shim
  - `get_formations()`
  - `find_formation_by_pattern(pattern)`
- Content layout expectations:
  - canonical source: `res://content/*.json`
  - legacy alias: `res://data/json/*.json`
  - required canonical files: `characters.json`, `formations.json`, `skills.json`, `levels.json`
  - `formations.json` records must include `id`, `name`, `effect`, `description`, and a non-empty `pattern` array of `{x:int, y:int}`
  - all domain records must expose a stable string `id`
- Behavioral expectations:
  - prefer canonical content when both canonical and legacy files exist
  - return typed empty dictionaries and warnings for missing ids instead of throwing
  - keep validation strict enough that broken content fails repository audit before merge
