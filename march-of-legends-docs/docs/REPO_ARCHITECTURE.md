# Repo Architecture

## Root layout

```text
march-of-legends/
├─ godot/
│  ├─ project.godot
│  ├─ icon.svg
│  ├─ scenes/
│  │  ├─ core/
│  │  ├─ world/
│  │  ├─ battle/
│  │  ├─ ui/
│  │  ├─ band/
│  │  ├─ characters/
│  │  └─ levels/
│  ├─ scripts/
│  │  ├─ autoload/
│  │  ├─ core/
│  │  ├─ battle/
│  │  ├─ band/
│  │  ├─ ui/
│  │  ├─ world/
│  │  ├─ data/
│  │  └─ debug/
│  ├─ data/
│  │  ├─ json/
│  │  ├─ dialogue/
│  │  └─ design/
│  ├─ assets/
│  │  ├─ art/
│  │  ├─ audio/
│  │  ├─ fonts/
│  │  └─ placeholder/
│  ├─ prompts/
│  └─ tests/
├─ notion_import/
└─ docs/
```

## Architecture principles

### 1. Scene-first
In Godot, scenes are your deployable chunks of reality. Every major gameplay mode gets its own scene subtree.

### 2. Data-driven where possible
Characters, formations, moves, enemies, and songs should live in JSON or Resources so agents can edit data without touching gameplay code.

### 3. Hard mode avoided
No multiplayer. No procedural open world. No 3D. No bespoke shader labyrinth. Keep the weirdness in the fiction, not the toolchain.

### 4. Vertical-slice first
Build one playable loop:
- walk campus
- talk to NPC
- enter rehearsal
- execute formation command
- trigger rhythm battle
- win encounter
- return to hub

That slice is the entire cathedral in miniature.

## Core Godot scenes

### `scenes/core/Main.tscn`
Bootstrap root. Owns scene transitions and top-level UI.

### `scenes/world/Campus.tscn`
Top-down exploration map.

### `scenes/band/FieldCommand.tscn`
Formation gameplay map and grid.

### `scenes/battle/RhythmBattle.tscn`
Rhythm duel scene.

### `scenes/ui/HUD.tscn`
Shared overlay UI.

### `scenes/ui/MainMenu.tscn`
Main menu.

## Autoload singletons

### `GameState.gd`
Global save-state-lite and run-state.

### `SceneRouter.gd`
Centralized scene switching.

### `AudioManager.gd`
Music and SFX routing.

### `ContentDB.gd`
Loads JSON content into memory.

## Data folders

### `data/json/characters.json`
Party members, rivals, mascot, bosses.

### `data/json/formations.json`
Named shape patterns and gameplay effects.

### `data/json/skills.json`
Skill trees and move metadata.

### `data/json/levels.json`
Level metadata.

### `data/dialogue/`
Dialogue scripts in JSON.

## Asset strategy

### Placeholder first
Use primitives and generated placeholders until the loop works.

### AI art second
Only after movement, encounters, and UI feel real.

### Polished sprite sheets last
Do not waste three days lovingly drawing a tuba before collision works.
