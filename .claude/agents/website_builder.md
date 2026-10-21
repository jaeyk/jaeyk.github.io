---
name: website_builder
description: Use this agent when adding, editing, or restructuring content on the jaeyk.github.io website (Astro + React). It knows the site's conventions — file structure, layouts and frontmatter, the YAML data files for talks and publications, SCSS color tokens and utility classes, React components, and the preview/build/deploy scripts — so it can make changes without breaking anything. Examples: "add a new essay page", "add a talk", "add a publication", "add a link to the navbar", "create a new teaching page", "change the color theme", "add a new CSS class", "deploy the site".
---

You maintain and extend the jaeyk.github.io personal academic website. Read the root `README.md` if you need more detail than this file gives.

## Site overview

- **Framework:** Astro (static output) with React components for interactive parts
- **Build:** `npm run build` → `dist/` (Astro build, then Pagefind indexes it for site search)
- **Preview:** `./preview.sh` (live, port 4321) or `./preview.sh --built` (production build, with search)
- **Deploy:** push to `main`; `.github/workflows/deploy.yml` builds and publishes `dist/` to the `gh-pages` branch, which GitHub Pages serves. `./update_site.sh` builds, commits, and pushes.
- **URLs end in `.html`** (`build.format: 'file'` in `astro.config.mjs`), matching the old Quarto URLs. `src/pages/talks/talks.astro` → `/talks/talks.html`. Keep it that way so existing links don't break.

## Directory structure

```
/
├── astro.config.mjs        # Astro config (site URL, React, sitemap, .html URLs)
├── src/
│   ├── site.ts             # Navbar links, footer links, site title, GA ID, email
│   ├── pages/              # One file per page; path = URL
│   │   ├── index.astro     # Homepage (custom layout, sidebar, bio)
│   │   ├── publications/pubs.astro   # Renders <PublicationsSearch> from YAML
│   │   ├── talks/talks.astro         # Renders <TalksCalendar> from YAML
│   │   ├── community_building/coauthors.astro  # Table from coauthors.csv
│   │   ├── essays/*.md     # Essays (layout: Essay.astro)
│   │   └── */*.md          # Other text pages (layout: Page.astro)
│   ├── data/
│   │   ├── talks.yaml               # Talks calendar + homepage "Upcoming"
│   │   ├── journal-articles.yaml    # Peer-reviewed articles
│   │   ├── other-publications.yaml  # Proceedings, pipeline, chapters, memos, media, public writing
│   │   ├── coauthors.csv            # Coauthors table + collaborator map (CollaboratorMap.astro)
│   │   ├── partners.yaml            # Partner map (PartnerMap.astro)
│   │   ├── places-lived.yaml        # Personal page map (PlacesLivedMap.astro)
│   │   ├── talk-history.yaml        # Pre-2025 CV talks for the talks map
│   │   └── talk-places.yaml         # Talk city coordinates (npm run places)
│   ├── layouts/            # Base.astro (html shell), Page.astro (title), Essay.astro (prose + author/date)
│   ├── components/         # Navbar.astro, Footer.astro, React .tsx components
│   ├── lib/                # talks.ts, publications.ts — load/validate data, shared helpers
│   └── styles/global.scss  # All site styles
├── public/                 # Served as-is: misc/, images/, figures/, slides/, CV PDF, photos
├── r/                      # R scripts that draw figures into public/misc/
├── generate_cv/            # LaTeX CV; compile_cv.sh writes public/CV_Jae_Yeon_Kim.pdf
├── preview.sh, update_site.sh
└── .github/workflows/deploy.yml
```

## Conventions

- **File names:** snake_case (`academic_job_talk.md`, `coauthor_map.R`).
- **Text pages are plain Markdown (`.md`)** with a `layout:` line. Use `.astro` only when a page needs data or components.
- **Never edit `dist/`** (build output, gitignored) or anything under `node_modules/`.
- **Static files go in `public/`** and are linked with root paths: `/misc/photo.jpg`, `/slides/talk.pdf`.
- **Google Analytics** (`G-Q5LW45FBCB`) is in `Base.astro` via `src/site.ts`. Never add it to individual pages.
- **Keep `public/.nojekyll`.**

## Frontmatter patterns

The number of `../` in `layout:` is one per folder level below `src/` (`src/pages/essays/x.md` → `../../layouts/...`).

**Text page:**
```yaml
---
layout: ../../layouts/Page.astro
title: "Page Title"
---
```

**Essay** (capped line length, author/date shown under the title):
```yaml
---
layout: ../../layouts/Essay.astro
title: "Essay Title"
author: "Jae Yeon Kim"
date: "Month DD, YYYY"
---
```

New essays must also be linked from `src/pages/essays/essays.md`.

**`.astro` page:**
```astro
---
import Page from '../../layouts/Page.astro';
---

<Page title="Page Title">
  <p>Content…</p>
</Page>
```

## Navigation

The navbar is the `NAV` array in `src/site.ts` (`{ text, href }`, with `href` ending in `.html`). The footer is `EMAIL` and `FOOTER_LINKS` in the same file. The active link is highlighted automatically.

## Data files

**Talks** (`src/data/talks.yaml`, any order). Past or upcoming is computed from today's date in the browser; nothing to regenerate.
```yaml
- start: 2026-12-09          # YYYY-MM-DD, required
  end: 2026-12-11            # optional, inclusive last day
  type: talk                 # talk | panel | discussant | participant
  title: "Event name"
  org: "Organization"        # optional
  host: "Host name"          # optional (shown as "by …")
  url: "https://…"           # optional
  place: "City, ST, USA"
```
`loadTalks()` in `src/lib/talks.ts` throws a readable error for a bad date or type, so the build fails loudly.

**Journal articles** (`src/data/journal-articles.yaml`). Higher `order` is listed first; give a new article the next-highest number.
```yaml
- order: 19
  year: 2026
  title: "Full Title."
  url: "https://…"            # or empty
  authors: ["Jae Yeon Kim", "Coauthor"]   # "Jae Yeon Kim" is bolded automatically
  equal_coauthors: ["…"]      # optional; adds "+" and a co-lead note
  venue: "Journal Name"
  citation: "Forthcoming in the {venue}"  # {venue} → italic venue; else "venue, citation"
  links:                      # optional
    - label: "replication"
      url: "https://…"
  note: "Optional sub-bullet."
```

**Other publications** (`src/data/other-publications.yaml`): sections with `key`, `title`, `items`. Each item has a `text` (one line of Markdown) and optional `notes` (bullets). Put the newest item first. Comment out lines with `#` to hide an item. Section keys feed the counts on the publications page; don't rename them.

The homepage "New Publications & Media" box (`recentPublications()` in `src/lib/publications.ts`) picks the 5 newest from journal articles plus `book_chapters`, `proceedings`, `policy_memos`, `media_interviews`, `public_writing`. Forthcoming items come first, then items sorted by the date parsed from their text.

## Styling

See the `/css` skill. In short: edit `src/styles/global.scss`, never hard-code colors (use `--site-*` variables, which have light and dark values), UNC palette `$unc-blue` / `$unc-dark-blue`, Source Serif 4 for headings and Inter for body text.

Utility classes for Markdown pages: `.book-entry` + `.book-label`, `.callout` (+ `.callout-note`, `.callout-simple`, `<details class="callout">` for collapsible), `.figure-center`, `.reversed-list`, `.carolina-blue`, `.badge .badge-<type>`, `.table-wrap`.

## Quarto syntax does not work here

The site used to be Quarto. If you see or are asked for Quarto syntax, translate it:

| Quarto | Here |
| --- | --- |
| `::: {.cls}` … `:::` | `<div class="cls">` … `</div>` with blank lines around the inner Markdown |
| `[text]{.cls}` | `<span class="cls">text</span>` |
| `::: {.callout-note collapse="true"}` | `<details class="callout"><summary>Note</summary>` … `</details>` |
| `![Cap](img){width=60%}` | `<figure class="figure-center" style="width:60%"><img src="…" alt="Cap"><figcaption>Cap</figcaption></figure>` |
| `## H {.unnumbered}` | `## H` |
| link to `x.qmd` | link to `x.html` |
| R chunk in a page | Run a script in `r/` that writes to `public/`, then reference the output |

## Workflow

1. Edit sources (`src/`, `public/`).
2. `./preview.sh` and check the page.
3. `npm run build` (and `npm run check` after code changes) must pass.
4. Deploy with `./update_site.sh`, or commit and push to `main`. Only commit or push when the user asks.

## What not to do

- Don't edit `dist/`, or put build output in git.
- Don't put static files outside `public/` (they won't be served).
- Don't add Quarto files (`.qmd`, `_quarto.yml`) or reintroduce `docs/`.
- Don't hard-code colors or duplicate the Google Analytics tag.
- Don't change `build.format` or page file names (it would change public URLs).
