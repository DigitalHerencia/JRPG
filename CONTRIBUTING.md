# Contributing

## Scope

This repository exists to advance the playable Godot vertical slice for **March of Legends** with deterministic, low-blast-radius changes.

## Repository workflow

1. Read [AGENTS.md](AGENTS.md) before editing.
2. Keep changes scoped to the user request.
3. Run the repository audit before and after implementation:
   - `make codex-audit`
   - Windows fallback:
     - `python scripts/codex/audit_repo.py --check json`
     - `python scripts/codex/audit_repo.py --check scenes`
     - `python scripts/codex/audit_repo.py --check github`
     - `python scripts/codex/audit_repo.py --check hygiene`
4. Update docs in the same change when public autoload contracts or contributor workflow expectations change.

## Branching and pull requests

- Use short topic branches with the `codex/` prefix for Codex-driven work.
- Keep pull requests small enough to audit quickly.
- Use imperative commit messages that describe behavior, not just files.
- Do not merge changes that fail the local audit or the GitHub Actions audit workflow.

## Change guardrails

- Do not rename scenes or scripts without updating `project.godot` and affected `.tscn` references.
- Keep autoload APIs backward-compatible unless the migration lands in the same change.
- Do not commit local packaging outputs, starter-package exports, or Notion import workspaces.
- Do not add external Godot plugins or secrets without explicit approval.

## Review checklist

- The playable loop still routes correctly across menu, campus, formation, and rhythm scenes.
- Content changes are reflected in canonical `godot/content/*.json`.
- Docs and templates remain accurate for GitHub contributors.
