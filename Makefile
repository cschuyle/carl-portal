.PHONY: watch deploy hooks build

# deploy: hooks → build → commit HTML if changed → require clean tree → push

watch:
	@chmod +x watch-render.sh 2>/dev/null || true
	./watch-render.sh

hooks:
	@chmod +x scripts/install-git-hooks.sh .githooks/pre-commit 2>/dev/null || true
	./scripts/install-git-hooks.sh

build:
	@chmod +x build.sh 2>/dev/null || true
	./build.sh

deploy: hooks build
	@git diff --quiet HEAD -- index.html cv.html 2>/dev/null || (git add index.html cv.html && git commit -m "chore: rebuild static HTML ($$(date +%Y-%m-%d))")
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo >&2 "deploy: uncommitted changes remain — commit or stash before pushing."; \
		git status --short >&2; \
		exit 1; \
	fi
	@git push
