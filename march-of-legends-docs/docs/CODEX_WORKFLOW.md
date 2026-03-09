# Codex Agentic Workflow (Optimized)

## Objective
Create predictable, low-blast-radius changes with fast feedback loops for the March of Legends Godot vertical slice.

## Workflow stages

### 1) Intake and scoping
- Restate user objective and impacted domain (`world`, `battle`, `ui`, `autoload`, `content`).
- Identify exact files to touch before editing.
- Reject unrelated refactors.

### 2) Audit baseline
Run:
- `make codex-audit`

This catches:
- malformed or missing JSON content files,
- missing scene script references,
- broken autoload script targets.
- missing GitHub community standards files,
- tracked local-only packaging/import paths.
- CI mirrors these checks in `.github/workflows/codex-audit.yml`; keep local and CI audit behavior aligned.

### 3) Implement change
- Keep functions small and explicit.
- Prefer additive changes over rewrites.
- Preserve public autoload method contracts unless migration is included.

### 4) Verify
Run:
- `make codex-audit`
- Windows fallback:
  - `python scripts/codex/audit_repo.py --check json`
  - `python scripts/codex/audit_repo.py --check scenes`
  - `python scripts/codex/audit_repo.py --check github`
  - `python scripts/codex/audit_repo.py --check hygiene`
- any feature-specific checks introduced by the change.
- if autoload behavior changes, re-check `docs/AUTOLOAD_CONTRACTS.md` and update it in the same change.

### 5) Delivery format
Every delivery should include:
1. Architectural note
2. Files changed
3. Assumptions
4. Risks and follow-ups
5. Validation command output summary

## File ownership matrix
- `scripts/autoload/*`: global state, routing, content loading, audio service.
- `scripts/world/*`: traversal and interactable logic.
- `scripts/band/*`: formation mode and tactical validation.
- `scripts/battle/*`: rhythm lane timing and scoring.
- `data/json/*`: gameplay content source of truth.

## Safety and quality rules
- Never log credentials or local machine secrets.
- Do not trust external input without validation.
- Keep state transitions explicit and observable.
- Prefer deterministic scripts for repeated validation.
