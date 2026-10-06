# gitpay.ru — landing

Landing site for **Гит Пэй Рус / GitPay RU**: AI agents for business processes.
Jekyll 4, no JavaScript build step, no CSS framework — plain Liquid + SCSS + a
small progressive-enhancement script.

- RU (default): `/`
- EN: `/en/`

---

## Run locally with Docker (recommended)

Requirements: Docker + Docker Compose v2.

```bash
docker compose up -d
```

Then open <http://localhost:4000>.

The site is served with **live reload**: edit any file, the page in your browser
reloads automatically (no manual refresh).

```bash
docker compose logs -f site     # follow the build log
docker compose restart site     # needed after editing _config.yml (see below)
docker compose down             # stop
docker compose down -v          # stop and delete gems/cache volumes
```

Ports can be changed without touching the compose file:

```bash
JEKYLL_PORT=8080 LIVERELOAD_PORT=35730 docker compose up -d
```

### How auto-reload works

| Piece | What it does |
| --- | --- |
| `--force_polling` | inotify events do not propagate through bind mounts, so Jekyll polls the file tree |
| `--livereload` | Jekyll injects a small script and pushes a reload event over the WebSocket on port `35729` |
| Live source | the repository is bind-mounted into `/site`, so the watcher sees your edits |
| `gems` / `jekyll-cache` volumes | dependencies and caches are kept outside the bind mount, so restarts are fast |

If your browser blocks the WebSocket, the page still updates — just refresh manually.

> `_config.yml` is **not** re-read by the watcher. After changing it, run
> `docker compose restart site` (or `up -d --force-recreate` if you changed the image).

---

## Run locally without Docker

Requires Ruby >= 3.1 (3.3 recommended).

```bash
bundle install
bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000
```

Open <http://localhost:4000>. Add `--force_polling` if file changes are not
detected (macOS/Windows or a network drive).

Production build (what CI publishes):

```bash
JEKYLL_ENV=production bundle exec jekyll build   # output in _site/
```

---

## Editing content

Almost all text lives in data files — no template edits needed.

| File | Contents |
| --- | --- |
| `_data/i18n/ru.yml`, `_data/i18n/en.yml` | all UI strings, both languages (same keys in both files) |
| `_data/agents.yml` | the agent catalogue; each entry has a `ru:` and an `en:` block |
| `_config.yml` | site name, e-mail, address, build options |
| `assets/img/og-image.png` | social preview image (1200×630) |

### Adding an agent

Append an item to `_data/agents.yml` — the grid re-flows automatically:

```yaml
- id: my-agent
  icon: "doc"            # see _includes/icon.html for available names
  ru:
    name: "Агент по заголовкам"
    tagline: "Короткое описание"
    text: "Пара абзацев о том, что делает агент."
    capabilities: ["Что умеет", "Ещё что умеет"]
    stack: ["LLM", "RAG"]
    integrations: ["1С", "REST API"]
    outcome: "Что изменится у клиента"
  en:
    # same keys, English
```

### Adding a language

1. Copy `_data/i18n/ru.yml` to `_data/i18n/<code>.yml`.
2. Add a page under `en/`-style directory with `lang: <code>` and a `lang_url`
   pointing at the default-language page.
3. Extend the `lang` switcher in `_includes/header.html` and
   `_includes/footer.html`.

### Adding a section

`_layouts/home.html` renders the landing sections in order; snippets live in
`_includes/` (`cta.html`, `icon.html`, `head.html`, `header.html`, `footer.html`).
Style with the helpers in `_sass/_tokens.scss` (colours, radii, breakpoints).

> The copy in `_data/` is a draft — adjust names, numbers and claims to match
> what you actually deliver before publishing.

---

## Project layout

```
├── _data/i18n/          translations (ru, en)
├── _data/agents.yml     agent catalogue
├── _includes/           header, footer, head, cta, icons
├── _layouts/            default (shell) and home (landing sections)
├── _sass/               design tokens, base, components, layout
├── assets/              css, js, images
├── en/                  English pages
├── index.html           RU landing
├── contacts.html        contacts page
├── 404.html             not found
├── Dockerfile           dev/prod image
├── docker-compose.yml   local dev server with auto-reload
└── .github/workflows/   build + deploy to GitHub Pages
```

---

## Deployment

`.github/workflows/deploy.yml` builds the site with Jekyll 4 and publishes it to
GitHub Pages (custom domain from `CNAME`). The built-in GitHub Pages builder
cannot compile Jekyll 4, which is why the site is published from CI instead.

Any other host works too — `bundle exec jekyll build` produces a fully static
`_site/` directory that can be served by nginx, Caddy or an object store.

---

## Notes

- Jekyll 4.4 (was 3.9 via `github-pages`); `minima` theme replaced by
  `_layouts/` + `_sass/`.
- Zero runtime dependencies: no framework, no webfont requests, no trackers.
- Accessibility: skip link, focus-visible outlines, ARIA on the menu and the
  language switcher, `prefers-reduced-motion` respected, all animations are
  progressive enhancements.
