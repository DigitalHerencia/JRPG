# March of Legends Workspace

This repository contains the Godot starter project and documentation for building the **March of Legends** vertical slice.

## Repository layout

- `march-of-legends-godot-project/godot/` — Godot 4 project (scenes, scripts, content JSON).
- `march-of-legends-docs/docs/` — architecture, setup, and process docs.
- `scripts/codex/` — Codex automation scripts for deterministic repository audits.

## Codex-first workflow

1. Run baseline checks:
   - `make codex-audit`
2. Implement scoped changes only.
3. Re-run checks:
   - `make codex-audit`
4. Commit with an imperative message describing behavioral impact.

## Primary references

- `AGENTS.md` (repo-wide agent operating contract)
- `march-of-legends-docs/docs/CODEX_WORKFLOW.md`
- `march-of-legends-docs/docs/REPO_ARCHITECTURE.md`
- `march-of-legends-godot-project/godot/README.md`
