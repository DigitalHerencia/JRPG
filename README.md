# March of Legends Workspace

![Codex Audit](https://github.com/DigitalHerencia/JRPG/actions/workflows/codex-audit.yml/badge.svg)
![Package Artifacts](https://github.com/DigitalHerencia/JRPG/actions/workflows/package-artifacts.yml/badge.svg)

This repository contains the Godot vertical-slice project and the supporting design, workflow, and release documentation for **March of Legends**.

## Repository layout

- `march-of-legends-godot-project/godot/` - Godot 4 runtime project with scenes, scripts, and canonical content JSON.
- `march-of-legends-docs/docs/` - architecture, process, setup, and autoload contract documentation.
- `scripts/codex/` - deterministic repository audits used locally and in GitHub Actions.

## Quick start

1. Review [AGENTS.md](AGENTS.md) and [CODEX_WORKFLOW.md](march-of-legends-docs/docs/CODEX_WORKFLOW.md).
2. Run the baseline repository audit:
   - `make codex-audit`
   - Windows fallback: `python scripts/codex/audit_repo.py --check json`, `--check scenes`, `--check github`, `--check hygiene`
3. Make the smallest change that satisfies the request.
4. Re-run the same audit checks before opening or merging a pull request.

## GitHub standards

- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- Pull request template: [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)
- Issue templates: [.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE)

## Primary references

- [march-of-legends-docs/docs/REPO_ARCHITECTURE.md](march-of-legends-docs/docs/REPO_ARCHITECTURE.md)
- [march-of-legends-docs/docs/AUTOLOAD_CONTRACTS.md](march-of-legends-docs/docs/AUTOLOAD_CONTRACTS.md)
- [march-of-legends-godot-project/godot/README.md](march-of-legends-godot-project/godot/README.md)
