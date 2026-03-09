# TODO

## 1) Gameplay tuning

- [ ] **Movement feel:** Capture baseline movement telemetry (acceleration curve, max speed, stop distance) from one representative level and document target values for tuning.
  - **Next step:** Add a short benchmark script/log pass and compare current values against intended feel targets.
  - **File/module pointer:** `player_controller` movement update loop (e.g., `src/gameplay/player_controller.*`).

- [ ] **Rhythm timing windows:** Define explicit timing window thresholds (Perfect/Great/Good/Miss in milliseconds) and externalize them into tunable data.
  - **Next step:** Move hardcoded judgment thresholds into a config/data asset and add a quick validation check for ascending window ranges.
  - **File/module pointer:** rhythm judgment service/module (e.g., `src/rhythm/timing_judger.*`, `data/rhythm/windows.*`).

- [ ] **Formation UX:** Reduce formation-change friction by validating input flow (open menu -> select slot -> confirm swap -> clear feedback) with controller and keyboard.
  - **Next step:** Create a task list for interaction states, then add missing visual/audio confirmation states where ambiguity exists.
  - **File/module pointer:** formation UI state machine and input handlers (e.g., `src/ui/formation/*`, `src/input/*`).

## 2) Bug backlog

- [ ] **Backlog template adoption:** Standardize bug entries to require reproducible steps, severity, and explicit owner.
  - **Next step:** Create/update bug template and migrate existing open bugs into the format below.
  - **File/module pointer:** issue tracker template docs (e.g., `docs/bugs.md` or `.github/ISSUE_TEMPLATE/bug_report.md`).

### Bug entry format (required)

- **Title:** `<short bug summary>`
- **Repro steps:**
  1. `<step 1>`
  2. `<step 2>`
  3. `<expected vs actual>`
- **Severity:** `<S1 | S2 | S3 | S4>`
- **Owner:** `<team/person placeholder>`
- **Module pointer:** `<path/module where fix likely belongs>`

## 3) Technical debt

- [ ] **Autoload contracts:** Enumerate all autoloaded/singleton services and define explicit initialization and lifecycle contracts.
  - **Next step:** Add contract documentation (required methods, side effects, dependency order) and flag violations.
  - **File/module pointer:** autoload registration/config and singleton implementations (e.g., `project.godot` autoload section, `src/autoload/*`).

- [ ] **Input mapping consistency:** Audit action names and bindings to eliminate duplicates, dead mappings, and naming drift across gameplay/UI contexts.
  - **Next step:** Produce a canonical input action matrix and update code references to a single action-name source.
  - **File/module pointer:** input map config and consumption sites (e.g., `project.godot` input map, `src/input/*`, `src/ui/*`).

- [ ] **Content schema validation:** Define machine-checkable schemas for gameplay/content data and fail CI on invalid content payloads.
  - **Next step:** Introduce schema definitions plus a validation script wired into CI pre-merge checks.
  - **File/module pointer:** content data directories and import/loader pipeline (e.g., `data/**/*`, `tools/validate_content.*`, `.github/workflows/*`).

## 4) Release criteria checklist (vertical slice acceptance)

- [ ] **Core loop completeness:** One end-to-end playable loop (explore -> encounter -> resolve -> rewards -> progression) is stable without blocker defects.
  - **Next step:** Run scripted smoke playthrough and log pass/fail against a fixed acceptance script.
  - **File/module pointer:** encounter flow/orchestration modules (e.g., `src/game_loop/*`, `src/battle/*`, `src/progression/*`).

- [ ] **Performance budget:** Scene and combat sequences meet agreed frame-time and memory budgets on target hardware profile.
  - **Next step:** Capture profiling traces for representative scenes and attach findings to the release gate artifact.
  - **File/module pointer:** performance-critical systems and profiling configs (e.g., `src/render/*`, `src/battle/*`, `docs/perf_targets.md`).

- [ ] **Input and UX readiness:** All critical flows are fully controllable with supported input devices and provide clear failure/success feedback.
  - **Next step:** Execute input UX checklist across keyboard/controller and file defects by severity.
  - **File/module pointer:** input abstraction + menu/navigation layers (e.g., `src/input/*`, `src/ui/*`).

- [ ] **Content sanity and stability:** No schema/content load errors, and save/load (if in-scope) survives a full vertical-slice session.
  - **Next step:** Run content validation plus a save/load regression scenario and archive logs.
  - **File/module pointer:** data loaders, serializers, and validation tools (e.g., `src/content/*`, `src/save/*`, `tools/validate_content.*`).

- [ ] **Acceptance sign-off package:** Build artifact, known-issues list, test summary, and rollback plan are prepared and reviewed.
  - **Next step:** Assemble release candidate checklist document and collect sign-offs from design, engineering, and QA.
  - **File/module pointer:** release docs and pipeline metadata (e.g., `docs/release_checklist.md`, `.github/workflows/release*`).
