.PHONY: codex-audit codex-json codex-scenes

codex-audit: codex-json codex-scenes
	@echo "[ok] codex audit completed"

codex-json:
	python3 scripts/codex/audit_repo.py --check json

codex-scenes:
	python3 scripts/codex/audit_repo.py --check scenes
