# March of Legends — Godot Project

This is a Godot 4 2D scaffold for a marching-band JRPG parody.

## Current included systems
- main menu
- scene routing
- campus exploration placeholder
- field command placeholder
- rhythm battle placeholder
- global game state singleton
- content database loader

## Next build target
Playable vertical slice:
1. boot to menu
2. enter campus
3. talk to mascot NPC
4. enter field command rehearsal
5. complete a simple line formation
6. trigger a rhythm duel
7. win and return to campus

## Content data layout
- Primary content source is `res://content/*.json` (characters, formations, skills, levels).
- `res://data/json/*.json` is treated as a legacy alias path for migration compatibility by `ContentDB` and emits warnings when used.
- Formation content is expected to carry strict 4-point `pattern` data for validation and lookup.
- Rhythm levels can embed a `rhythm` object with lane count, timing windows, approach timing, and ordered `chart_notes`.
