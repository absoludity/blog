# Live and let Learn

Personal blog ([liveandletlearn.net](https://liveandletlearn.net/)) built with
[Hugo](https://gohugo.io/). The Hugo toolchain (Hugo extended, Go for Hugo
Modules, Dart Sass, Node) and the [Vale](https://vale.sh/) prose linter all run
inside containers, so nothing needs to be installed on the host beyond a
container runtime (podman or docker).

## Commands

```bash
make          # list available targets
make dev      # serve the site with live reload at http://localhost:1313
make build    # build the production site into ./public
make new NAME=post/my-post/index.md   # scaffold content from an archetype
make check    # Vale-lint only new/changed markdown
make check-all # Vale-lint the whole back catalogue
make clean    # remove generated output (public/, resources/)
```

`make dev PORT=8080` changes the port; `CONTAINER_RUNTIME=docker` forces a
runtime when both podman and docker are installed. The first containerised run
downloads the Hugo module and Vale packages; both are cached under `.cache/`
(gitignored) so later runs are fast.

## Architecture

This is a Hugo site themed by the **HugoBlox** (formerly Wowchemy) framework,
pulled in as a Hugo Module — see `module.imports` in `config.yaml` and the
`require` entries in `go.mod`. There is no local theme to read: the bulk of the
layouts, partials, and styling live in that downloaded module. The
`beautifulhugo` entry in `.gitmodules` is a leftover and is not used (the
`themes/` directory is empty and nothing references it).

`config.yaml` is the single source of site configuration. Beyond standard Hugo
settings it drives HugoBlox-specific behaviour: `params.appearance` (theme/font),
`params.features` (syntax highlighting, math, Wowchemy search, giscus comments),
and the `tags` / `categories` / `authors` taxonomies.

### Content

- `content/post/` holds blog posts, as either a single `name.md` file or a
  page bundle (`name/index.md` with co-located images such as `featured.jpg`).
  Posts in a bundle directory like `learning-to-paraglide/` use an `_index.md`
  as the series landing page.
- Front matter sets `categories`, `tags`, and `commentable`. The `tags` value
  doubles as a content type: `article`, `note`, etc. (`archetypes/` has matching
  templates — `hugo new post/...` / `note/...`).
- **Series**: a post joins a series via a `series:` front-matter list. The
  `series-nav` partial/shortcode finds other pages sharing that series value and
  renders a banner linking to `/post/<series>/`. The series name must match a
  page bundle slug under `content/post/` for the banner to use its title.

### Custom layouts

`layouts/` overrides only what the HugoBlox module does not provide:

- `shortcodes/` — `asciicast` and `ayvri` (embeds), `manilla-disclaimer`
  (per-day disclaimer used in the paraglide series), and `series-nav`.
- `partials/series-nav.html` (the series banner logic) and
  `partials/partials/comments/giscus.html` (overrides the module's giscus
  partial; comments are configured under `params.features.comment`).

## Prose linting

`.vale.ini` configures Vale. Synced packages (Microsoft, write-good, alex) land
in `.vale/styles/` and are gitignored; the custom `Blog` style
(`.vale/styles/Blog/BritishSpelling.yml`, an American→British substitution rule)
and the `Blog` vocabulary (`.vale/styles/config/vocabularies/Blog/`) are
version-controlled. Add accepted project terms (technical names, etc.) to
`accept.txt` to silence `Vale.Spelling` false positives.

The existing back catalogue predates the linter and has many findings, so
`make check` lints only **new or changed** markdown under `content/` (working-tree
modifications plus untracked files). Add `BASE=<ref>` (e.g. `BASE=origin/main`)
to also include markdown committed since that ref; `make check-all` lints
everything. Both lint markdown only — pointing Vale at the whole `content/`
directory makes it try to lint the page-bundle images, which is pathologically
slow. See [README.md](README.md) for per-file usage and inline suppression.

## Deployment

`.github/workflows/hugo.yml` builds the site with Hugo and deploys to GitHub
Pages on every push to `main`. The pinned `HUGO_VERSION` there must stay in sync
with `HUGO_VERSION` in the `Makefile`.
