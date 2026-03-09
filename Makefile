.PHONY: codex-audit codex-json codex-scenes codex-github codex-hygiene

codex-audit: codex-json codex-scenes codex-github codex-hygiene
	@echo "[ok] codex audit completed"

codex-json:
	python3 scripts/codex/audit_repo.py --check json

codex-scenes:
	python3 scripts/codex/audit_repo.py --check scenes

codex-github:
	python3 scripts/codex/audit_repo.py --check github

codex-hygiene:
	python3 scripts/codex/audit_repo.py --check hygiene
