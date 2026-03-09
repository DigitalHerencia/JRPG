# AGENTS.md

## Scope
These instructions apply to the entire repository.

## Mission
Use Codex to build and maintain the Godot vertical slice with production discipline:
- small, composable changes
- deterministic validation commands
- explicit rollback paths

## Repository map
- `march-of-legends-godot-project/godot/`: runtime project (scenes, scripts, data)
- `march-of-legends-docs/docs/`: design and process documentation
- `scripts/codex/`: automation for repository audits and agent workflow checks

## Required execution workflow
1. **Audit first**
   - Run `make codex-audit` before implementation.
2. **Implement narrowly**
   - Touch only files required for the requested change.
3. **Validate**
   - Re-run `make codex-audit` and any task-specific checks.
4. **Report**
   - Summarize architecture impact, assumptions, risks, and follow-ups.

## Change guardrails
- Do not rename scenes or scripts without updating references in `project.godot` and `.tscn` files.
- Do not introduce external Godot plugins without explicit approval.
- Keep autoload APIs backward-compatible unless migration is included in the same change.
- Do not commit secrets, credentials, or local machine paths.

## Definition of done
A change is done only when:
- audit checks pass,
- changed files are cited in final report,
- commit message describes impact in imperative mood.
