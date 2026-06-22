.PHONY: help dev build new check check-all clean

# Hugo and Vale always run in a container (podman or docker) so the site builds
# without installing Hugo, Go, Dart Sass, or Vale on the host. Pick a runtime
# with `CONTAINER_RUNTIME=docker`; override the port with `make dev PORT=8080`.
#
# Keep HUGO_VERSION in sync with .github/workflows/hugo.yml.
HUGO_VERSION ?= 0.150.0
HUGO_IMAGE   := hugomods/hugo:exts-$(HUGO_VERSION)
VALE_IMAGE   := jdkato/vale:latest
PORT         ?= 1313

# Stamp marking the last successful `vale sync`, so packages are only synced once.
VALE_STAMP   := .vale/styles/.synced

# Prefer the real `podman` binary over a `docker` shim that wraps it.
CONTAINER_RUNTIME ?= $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)
ifeq ($(CONTAINER_RUNTIME),)
$(error no container runtime found — install podman or docker)
endif

# Attach a TTY only when one is present, so `make build`/`check` work in CI.
TTY := $(shell [ -t 0 ] && echo -it)

# podman and rootless docker both map the container's root to the host user, so
# bind-mounted files keep host ownership and we run as root inside. Only rootful
# docker needs --user + a writable HOME (HOME=/tmp) for an arbitrary uid.
ifeq ($(findstring podman,$(CONTAINER_RUNTIME)),)
ifeq ($(findstring rootless,$(shell $(CONTAINER_RUNTIME) info 2>/dev/null)),)
CONTAINER_USER := --user $(shell id -u):$(shell id -g) -e HOME=/tmp
endif
endif

# Persist Hugo's module/resource cache in .cache/ (gitignored) so module
# downloads and image processing are not repeated on every run.
CONTAINER_RUN = $(CONTAINER_RUNTIME) run --rm $(TTY) \
	-v $(CURDIR):/src -w /src \
	-v $(CURDIR)/.cache:/cache -e HUGO_CACHEDIR=/cache \
	$(CONTAINER_USER)

HUGO := $(CONTAINER_RUN) $(HUGO_IMAGE) hugo
# The jdkato/vale image's entrypoint is already `vale`, so no command is added.
VALE := $(CONTAINER_RUN) $(VALE_IMAGE)

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-8s %s\n", $$1, $$2}'

dev: ## Start the Hugo dev server at http://localhost:1313 (Ctrl-C to stop)
	$(CONTAINER_RUN) -p $(PORT):$(PORT) $(HUGO_IMAGE) \
		hugo server --bind 0.0.0.0 --port $(PORT) --baseURL http://localhost:$(PORT)/ --buildDrafts

build: ## Build the production site into ./public
	$(HUGO) --minify

new: ## Scaffold content from an archetype: make new NAME=post/my-post/index.md [KIND=note]
	@test -n "$(NAME)" || { \
	    echo "Usage: make new NAME=<path under content/> [KIND=<archetype>]"; \
	    echo "  e.g. make new NAME=post/my-first-post/index.md"; \
	    echo "       make new NAME=post/quick-thought.md KIND=note"; \
	    exit 1; }
	$(HUGO) new content $(if $(KIND),--kind $(KIND)) $(NAME)

check: $(VALE_STAMP) ## Lint only new/changed markdown (BASE=ref to also diff committed work)
	@files=$$( { \
	    git diff --name-only --diff-filter=d HEAD -- content; \
	    git ls-files --others --exclude-standard -- content; \
	    $(if $(BASE),git diff --name-only --diff-filter=d '$(BASE)' -- content;) \
	  } 2>/dev/null | grep -E '\.(md|mdx)$$' | sort -u ); \
	if [ -z "$$files" ]; then echo "No new or changed markdown to check."; exit 0; fi; \
	printf 'Checking:\n'; printf '  %s\n' $$files; \
	$(VALE) $$files

check-all: $(VALE_STAMP) ## Lint all content with Vale (the whole back catalogue)
	# Restrict to markdown: pointing Vale at the directory makes it try to lint
	# the images in page bundles, which is pathologically slow.
	$(VALE) --glob='*.{md,mdx}' content

# Sync Vale packages only when missing or when .vale.ini changes (e.g. the
# package list), rather than on every `make check`. The stamp lives alongside
# the synced styles so removing .vale/ forces a re-sync.
$(VALE_STAMP): .vale.ini
	$(VALE) sync
	@touch $@

clean: ## Remove generated output
	rm -rf public resources
