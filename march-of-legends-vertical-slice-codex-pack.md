# March of Legends — Vertical Slice Codex Pack

This pack is designed for **one-file-at-a-time vibe coding** against the exact scaffold already generated in `march-of-legends/godot`.

The goal is not “build the whole game.” That is how repos become haunted.  
The goal is:

**Menu → Campus → Field Command → Rhythm Battle → Return to Campus with progression state**

That is the vertical slice.

---

## 0) Ground Rules for Codex

Use these rules in **every** Codex session:

1. Work against the existing repo only. Do not re-architect the whole project.
2. Change the minimum number of files needed for the current task.
3. Prefer adding small helper scripts over bloating one giant script.
4. Keep all scene paths and autoload names compatible with the current scaffold.
5. Do not introduce C#, plugins, external services, or multiplayer.
6. Use **Godot 4 GDScript** only.
7. Preserve the loop: `MainMenu -> Campus -> FieldCommand -> RhythmBattle -> Campus`.
8. Add temporary placeholder UI and data where assets are missing.
9. Do not invent systems outside the current task.
10. After each task, summarize:
   - files changed
   - what works now
   - what remains blocked

---

## 1) Vertical Slice Success Criteria

By the end of this pack, the slice should do this:

- Launch into Main Menu
- Start a new rehearsal day
- Walk Leo around campus
- Talk to mascot and at least one section rival
- Enter Field Command practice
- Place marchers on a grid
- Evaluate the formation into a recognized spell
- Carry that spell into Rhythm Battle as a battle modifier
- Play a short rhythm encounter
- Award hype / discipline / improv based on performance
- Return to campus with state updated
- Show one short story beat acknowledging the result

---

## 2) Existing Scaffold Snapshot

Current important files:

- `project.godot`
- `scenes/core/Main.tscn`
- `scenes/ui/MainMenu.tscn`
- `scenes/world/Campus.tscn`
- `scenes/band/FieldCommand.tscn`
- `scenes/battle/RhythmBattle.tscn`
- `scripts/core/Main.gd`
- `scripts/ui/MainMenu.gd`
- `scripts/world/Campus.gd`
- `scripts/band/FieldCommand.gd`
- `scripts/battle/RhythmBattle.gd`
- `scripts/autoload/GameState.gd`
- `scripts/autoload/SceneRouter.gd`
- `scripts/autoload/AudioManager.gd`
- `scripts/autoload/ContentDB.gd`
- `data/json/characters.json`
- `data/json/formations.json`
- `data/json/skills.json`
- `data/json/levels.json`

---

## 3) Master Codex Orchestrator Prompt

Use this once at the start of a session:

```text
You are implementing a Godot 4 vertical slice for an existing 2D pixel-art JRPG project called "March of Legends: First Chair."

Work ONLY against the existing scaffold already present in the repo.

Important constraints:
- GDScript only
- Godot 4.x
- Preserve existing autoload names: GameState, SceneRouter, AudioManager, ContentDB
- Do not rebuild the whole repo
- Do not introduce unnecessary abstractions
- Prefer small, testable, incremental edits
- Use placeholder visuals and labels where assets are missing
- Keep the project beginner-friendly and AI-maintainable

Current vertical slice target:
Main Menu -> Campus -> Field Command -> Rhythm Battle -> Campus

For each task:
1. Read the target file(s)
2. Implement only the requested scope
3. Keep scene/script paths compatible with the scaffold
4. Return the full replacement content for changed files
5. Briefly explain what changed
6. List any editor wiring steps if scene nodes are required

Do not touch unrelated files.
```

---

# 4) Ordered Implementation Tasks

These are in the order I would actually run them.  
Tiny goblin principle: **one stable brick at a time.**

---

## Task 01 — Stabilize Global Slice State

### Target files
- `scripts/autoload/GameState.gd`

### Goal
Turn `GameState` into the source of truth for the vertical slice result state:
- selected formation id / label
- rehearsal day state
- last battle result
- story flags
- stats for hype, discipline, improv

### Codex prompt
```text
Update `scripts/autoload/GameState.gd` for the current Godot 4 vertical slice.

Requirements:
- Keep the existing default party and existing stats idea
- Add typed fields for:
  - current_day_label
  - selected_formation_id
  - selected_formation_name
  - formation_bonus
  - last_battle_result
  - last_battle_grade
  - current_story_beat
- Add methods:
  - reset_run()
  - set_selected_formation(formation_id: String, formation_name: String, bonus := {})
  - set_battle_result(result: String, grade: String)
  - apply_post_battle_rewards(hype_delta: int, discipline_delta: int, improv_delta: int)
- Preserve existing methods where still useful
- Keep the script simple and beginner-readable
- Return the full replacement file content only
```

### Done when
- All slice systems can read/write shared state from one place
- No scene-specific logic lives in GameState

---

## Task 02 — Make ContentDB Actually Useful

### Target files
- `scripts/autoload/ContentDB.gd`
- `data/json/formations.json`
- `data/json/characters.json`
- `data/json/levels.json`

### Goal
Upgrade content data so the slice has meaningful content instead of thin placeholder mush.

### Codex prompt
```text
Upgrade the content-loading system for the current Godot 4 project.

Update `scripts/autoload/ContentDB.gd` and the JSON content files listed below.

Files:
- scripts/autoload/ContentDB.gd
- data/json/formations.json
- data/json/characters.json
- data/json/levels.json

Requirements:
1. Keep JSON loading simple using FileAccess and JSON.parse_string
2. Add getter methods:
   - get_level(id: String) -> Dictionary
   - get_all_formations() -> Array
   - get_party_characters() -> Array
3. Make formations.json include at least 4 formation entries:
   - line
   - column
   - box
   - jazz_sigil
   Each formation should include:
   - id
   - name
   - shape_hint
   - battle_bonus
   - description
4. Make characters.json include at least:
   - leo
   - dr_major
   - snare_kid
   - mascot_guide
   with section, archetype, short bio, and battle role
5. Make levels.json include at least:
   - campus_day_1
   - rehearsal_field
   - duel_practice
6. Keep the data compact and hand-editable
7. Return full replacement contents for all changed files
```

### Done when
- Formations can carry real gameplay metadata into the battle
- Characters and level metadata can drive dialogue and UI

---

## Task 03 — Route Transitions Without Nonsense

### Target files
- `scripts/autoload/SceneRouter.gd`

### Goal
Keep scene routing dead simple but robust enough for the slice.

### Codex prompt
```text
Refactor `scripts/autoload/SceneRouter.gd` for a Godot 4 vertical slice.

Requirements:
- Keep existing routes for main_menu, campus, field_command, rhythm_battle
- Add:
  - has_route(route_key: String) -> bool
  - get_route_path(route_key: String) -> String
- Improve goto(route_key: String) to:
  - guard unknown routes
  - avoid redundant scene reload if already on route and no force flag is used
- Support optional `force_reload := false`
- Keep GameState.current_scene_key updated
- Keep the file very small and readable
- Return full replacement file content only
```

### Done when
- Route changes are clean
- No accidental double-reloads during iteration

---

## Task 04 — Main Menu Should Start an Actual Run

### Target files
- `scripts/ui/MainMenu.gd`
- `scenes/ui/MainMenu.tscn` if required

### Goal
Starting the game should reset run state and enter a specific level context.

### Codex prompt
```text
Implement a proper vertical-slice start flow for the main menu.

Files:
- scripts/ui/MainMenu.gd
- scenes/ui/MainMenu.tscn (only if node wiring must change)

Requirements:
- Keep buttons for Start, Field, Rhythm, Quit
- Start button should:
  - call GameState.reset_run()
  - set GameState.current_story_beat to a day-1 opening beat
  - route to campus
- Add one visible label showing current version or slice name
- Keep direct jump buttons for debugging
- If scene nodes must change, provide full updated scene content and explain wiring
- Return full replacement contents for changed files
```

### Done when
- New run starts cleanly
- Debug shortcuts still exist

---

## Task 05 — Campus Scene Becomes a Real Hub

### Target files
- `scripts/world/Campus.gd`
- `scenes/world/Campus.tscn`

### Goal
Campus becomes the narrative and navigation hub instead of just a rectangle you scoot around like a lost trombone goblin.

### Codex prompt
```text
Upgrade the Campus scene into a real vertical-slice hub.

Files:
- scripts/world/Campus.gd
- scenes/world/Campus.tscn

Requirements:
- Keep player movement
- Add at least 3 interaction zones or interactables:
  1. mascot guide
  2. brass rival / bandmate
  3. rehearsal field entrance
- Show context-sensitive text in the info label
- Pressing interact near mascot should show a story beat based on GameState.current_story_beat
- Pressing interact near brass rival should show section-flavored dialogue
- Pressing interact near rehearsal field should route to field_command
- When returning from rhythm battle, the campus text should acknowledge the last battle result
- Use very simple Node2D/Area2D/ColorRect placeholders if needed
- Keep the script beginner-readable
- Return full replacement contents for all changed files
```

### Done when
- Campus feels like a playable hub
- Slice results are reflected in dialogue

---

## Task 06 — Field Command Needs Real Formation Recognition

### Target files
- `scripts/band/FieldCommand.gd`
- `data/json/formations.json`
- optionally new helper file: `scripts/band/FormationRecognizer.gd`

### Goal
Recognize formations in a way that maps to actual formation content, not just cute placeholder text.

### Codex prompt
```text
Implement actual vertical-slice formation recognition.

Files:
- scripts/band/FieldCommand.gd
- data/json/formations.json
- optionally scripts/band/FormationRecognizer.gd if you want to keep logic separate

Requirements:
- Keep click-to-place cells
- Evaluate selected cells into one of these formation ids:
  - line
  - column
  - box
  - jazz_sigil
- Use simple geometric heuristics based on selected cell bounds and count
- On accept:
  - detect the formation
  - look up formation data from ContentDB
  - write selected formation id/name/bonus into GameState
  - update the label before routing
- Add a way to clear the current selection
- Add a visible hint telling the player which formation was recognized
- If using a helper file, keep it tiny and pure-logic
- Return full replacement contents for all changed files
```

### Done when
- The formation result is no longer fake
- Battle modifiers can depend on recognized formation data

---

## Task 07 — Rhythm Battle Must Consume Formation Bonus

### Target files
- `scripts/battle/RhythmBattle.gd`

### Goal
Battle performance should depend partly on the formation picked in field command.

### Codex prompt
```text
Refactor `scripts/battle/RhythmBattle.gd` so the battle uses the selected formation bonus from GameState.

Requirements:
- Keep the current lightweight rhythm sequence approach
- Read GameState.selected_formation_name and GameState.formation_bonus
- Show the active formation at battle start
- Apply a simple bonus effect, such as:
  - extra starting combo
  - extra time
  - reduced penalty on a miss
  depending on the bonus data
- At battle end assign:
  - result (win or rehearsal_complete)
  - grade (S/A/B/C)
- Store result and grade in GameState
- Apply rewards through GameState.apply_post_battle_rewards(...)
- Return player to campus
- Keep the logic lightweight and readable
- Return full replacement file content only
```

### Done when
- Field Command actually matters
- Rhythm Battle produces stateful outcomes

---

## Task 08 — Add Battle HUD Feedback

### Target files
- `scenes/battle/RhythmBattle.tscn`
- `scripts/battle/RhythmBattle.gd`

### Goal
Make battle readable without real art yet.

### Codex prompt
```text
Improve the Rhythm Battle HUD for the existing vertical slice.

Files:
- scenes/battle/RhythmBattle.tscn
- scripts/battle/RhythmBattle.gd

Requirements:
- Keep current labels for combo and timer
- Add labels for:
  - active formation
  - expected input
  - grade preview or performance feedback
- Make the UI layout clear using placeholder controls only
- Avoid adding complex animations
- Keep scene and script simple enough for a beginner to inspect
- Return full replacement contents for changed files
```

### Done when
- Player can understand what the battle wants
- The battle no longer feels like occult spreadsheet combat

---

## Task 09 — Add a Post-Battle Story Beat on Campus

### Target files
- `scripts/world/Campus.gd`

### Goal
The loop must acknowledge success or failure narratively.

### Codex prompt
```text
Update `scripts/world/Campus.gd` so the campus scene reacts to post-battle results.

Requirements:
- When the scene loads after a battle, inspect:
  - GameState.last_battle_result
  - GameState.last_battle_grade
  - GameState.selected_formation_name
- Show one of several story beat messages:
  - triumphant if grade S or A
  - decent if grade B
  - embarrassing but funny if grade C
- The mascot interaction text should also change slightly after the battle
- Do not create a dialogue system yet; use clean conditional text only
- Return full replacement file content only
```

### Done when
- The loop feels connected
- The player sees consequences immediately

---

## Task 10 — Add a Simple Dialogue Data File

### Target files
- new file: `data/dialogue/day1_campus_intro.json`
- `scripts/world/Campus.gd` only if needed

### Goal
Start moving story copy out of scripts.

### Codex prompt
```text
Introduce lightweight external dialogue content for the day-1 campus slice.

Files:
- data/dialogue/day1_campus_intro.json
- scripts/world/Campus.gd (only if needed)

Requirements:
- Create a simple JSON file with keys for:
  - intro
  - mascot_pre_battle
  - rival_pre_battle
  - post_battle_s
  - post_battle_a
  - post_battle_b
  - post_battle_c
- If updating Campus.gd, load this file with very simple JSON parsing
- Keep the system tiny and local to the campus scene
- Do not build a global dialogue engine yet
- Return full replacement contents for changed files
```

### Done when
- Narrative content is less trapped inside script code
- Future story passes become easier

---

## Task 11 — Create a Reusable Interaction Helper

### Target files
- new file: `scripts/world/InteractableZone.gd`
- `scenes/world/Campus.tscn`
- `scripts/world/Campus.gd`

### Goal
Prevent Campus.gd from becoming a swamp beast.

### Codex prompt
```text
Create a tiny reusable interactable-zone helper for the Campus scene.

Files:
- scripts/world/InteractableZone.gd
- scenes/world/Campus.tscn
- scripts/world/Campus.gd

Requirements:
- InteractableZone should expose:
  - interactable_id
  - display_name
  - prompt_text
- Campus.gd should detect the nearest active interactable instead of hardcoding every overlap inline
- Keep the system tiny and local to this slice
- Use Area2D if helpful, but keep node structure simple
- Return full replacement contents for changed files
```

### Done when
- Campus interactions scale without immediate chaos
- The file structure becomes more agent-friendly

---

## Task 12 — Build a Slice QA Checklist

### Target files
- new file: `tests/vertical_slice_manual_qa.md`

### Goal
Agents need a human-readable smoke test after each pass.

### Codex prompt
```text
Create `tests/vertical_slice_manual_qa.md` for the current Godot project.

Requirements:
- Include a concise manual test checklist for:
  - app boot
  - main menu buttons
  - campus movement
  - mascot interaction
  - rival interaction
  - entering field command
  - selecting and clearing formation cells
  - recognized formation display
  - entering rhythm battle
  - combo / miss behavior
  - battle completion
  - return to campus
  - stat persistence
- Keep it practical and short
- Return the full new file content only
```

### Done when
- Each Codex pass can be sanity-checked quickly

---

# 5) Optional Next-Tier Tasks After the Slice Works

Do not do these until the slice runs clean.

---

## Task 13 — Add Scene Transition Overlay

### Target files
- new file: `scenes/ui/SceneFade.tscn`
- new file: `scripts/ui/SceneFade.gd`
- `scripts/autoload/SceneRouter.gd`

### Prompt
```text
Add a tiny fade overlay transition system to smooth route changes between existing scenes.

Keep it minimal:
- CanvasLayer based
- fade out -> scene change -> fade in
- optional, non-blocking, no plugin
- preserve existing SceneRouter API as much as possible
```

---

## Task 14 — Add Practice Scoring Screen

### Target files
- new file: `scenes/ui/ResultsPopup.tscn`
- new file: `scripts/ui/ResultsPopup.gd`
- `scripts/battle/RhythmBattle.gd`

### Prompt
```text
Add a lightweight end-of-battle results popup showing:
- grade
- combo
- formation used
- rewards gained

Use simple placeholder UI only.
```

---

## Task 15 — Add One Rival Duel Variant

### Target files
- `data/json/levels.json`
- `scripts/world/Campus.gd`
- `scripts/battle/RhythmBattle.gd`

### Prompt
```text
Add a second rhythm encounter variant representing a brass rival practice duel.

Requirements:
- trigger from campus rival interaction
- use a slightly different note sequence
- show different dialogue flavor
- keep all logic small and data-driven where practical
```

---

# 6) Asset Tasks for AI Image Generation

These are **not** code tasks. These are art pipeline prompts for ChatGPT image generation.

---

## Leo sprite sheet concept
```text
Create SNES-style pixel art concept art for a freshman trombone prodigy at a desert university marching band. He wears a crimson-and-white parody collegiate band uniform, carries a trombone, and has an earnest anime-JRPG protagonist vibe. Full-body character sheet feel, readable silhouette, 16-bit era color palette, expressive but not hyper-detailed.
```

## Mascot guide concept
```text
Create SNES-style pixel art concept art for a ridiculous university mascot who acts like a mystical spirit guide in a parody JRPG. He is theatrical, smug, slightly unhinged, wearing a marching-band-themed costume in a desert university setting. Funny but weirdly majestic.
```

## Campus background concept
```text
Create pixel art concept art for a Southwestern university campus inspired by late-SNES JRPG overworld towns, with rehearsal spaces, stadium hints, warm desert colors, dramatic skies, and a whimsical marching-band tone.
```

## Rhythm battle UI concept
```text
Create pixel-art JRPG battle UI mockup mixed with rhythm-game note lanes, suitable for a marching-band-themed game. Readable, colorful, SNES-inspired, high contrast, placeholder-friendly layout.
```

---

# 7) Suggested Session Rhythm for You

This is the practical loop.

1. Open one prompt.
2. Run it in Codex against the repo.
3. Paste/apply the file changes.
4. Open Godot and test the slice.
5. Fix only the broken thing.
6. Move to the next prompt.

Do **not** ask the model to “finish the whole game.”  
That is how you summon procedural sadness.

---

# 8) Why This Sequence Is Correct

This sequence leans on Godot’s existing scaffold model:
- autoloads are appropriate for broad-scope systems like shared game state and scene routing,
- while scene-specific logic should stay local to the relevant scene or helper node.  
That is aligned with Godot’s guidance on autoloads and broad-scoped systems.  
It also keeps the project grounded in a 2D-first workflow rather than prematurely inventing exotic machinery.  
See Godot’s documentation on autoload usage and best practices:
- https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html
- https://docs.godotengine.org/en/4.0/tutorials/best_practices/autoloads_versus_internal_nodes.html

---

# 9) Fastest Path to “This Is Actually Playable”

If you only do five tasks first, do these:

1. Task 01 — GameState
2. Task 02 — ContentDB + JSON
3. Task 05 — Campus
4. Task 06 — Field Command
5. Task 07 — Rhythm Battle

That gives you the core loop.

Everything else is polish, clarity, and future-proofing.

---

# 10) Final Instruction Block for Codex

Use this as the repeating footer in every session:

```text
Before you answer:
- inspect the existing file content
- preserve compatible paths and node names
- keep the change set minimal
- do not rewrite unrelated systems
- return complete replacement content for each changed file
- call out any scene-node wiring the editor must do manually

After you answer:
- include a 5-bullet smoke test for the change
- include the exact files changed
- list any follow-up task that should come next
```
