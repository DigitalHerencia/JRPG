# Godot Builder Prompt

Work only on the Godot implementation.

## Current repo intent
This repo uses:
- `scenes/` for Godot scenes
- `scripts/` for logic
- `data/json/` for content definitions

## Rules
- prefer additive scripts
- use signals where useful
- keep scene ownership clear
- if introducing new input actions, update `project.godot`
- if using data, prefer loading from `ContentDB`

## Task template
Build or improve one of the following:
- player movement
- NPC interaction
- formation selection UI
- rhythm lane timing system
- win/lose state handling
- save/load stub

Output exact files and code.
