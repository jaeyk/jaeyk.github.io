# jaeyk.github.io

Source for [Jae Yeon Kim](https://jaeyk.github.io)'s academic website. It's
built with [Astro](https://astro.build), with a few interactive parts written
in React, and served by GitHub Pages.

This README is written for someone who knows Quarto. The [cheat sheet
below](#quarto--astro-cheat-sheet) maps each Quarto habit to its equivalent
here.

---

## Quick start

You need [Node.js](https://nodejs.org) 22 or newer. Check with `node -v`.

```sh
./preview.sh            # live preview at http://localhost:4321, refreshes as you save
./preview.sh --built    # preview the finished site, including site search
./update_site.sh        # rebuild, commit, and push; GitHub then publishes the site
```

The first run of either script installs dependencies automatically.

---

## How publishing works

1. You edit files and preview with `./preview.sh`.
2. `./update_site.sh` checks that the site builds, then commits and pushes.
3. On every push to `main`, GitHub Actions ([`.github/workflows/deploy.yml`](.github/workflows/deploy.yml))
   builds the site and publishes it to the `gh-pages` branch. The live site
   updates a minute or two later. You can watch progress in the repo's
   **Actions** tab, or rerun a deploy there with **Run workflow**.

Unlike the old Quarto setup, you never commit built HTML: there is no `docs/`
folder. The `dist/` folder that builds create is ignored by git.

`update_site.sh` options:

| Option | What it does |
| --- | --- |
| *(none)* | Recompiles the CV if `cv_Kim.tex` changed, reruns the R maps, builds, commits, pushes |
| `--force-cv` | Recompiles the CV even if the `.tex` didn't change |
| `--skip-maps` | Skips the R map scripts (faster; use when the maps haven't changed) |
| `-m "message"` | Uses your own commit message |

---

## Common tasks

### Add a talk or event

Add an entry anywhere in [`src/data/talks.yaml`](src/data/talks.yaml); order
doesn't matter:

```yaml
- start: 2026-12-09
  end: 2026-12-11          # optional: last day of a multi-day event
  type: talk               # talk | panel | discussant | participant
  title: "Name of the event"
  org: "Hosting organization"   # optional
  host: "Person who invited you" # optional
  url: "https://..."             # optional
  place: "Boston, MA, USA"
```

The talks calendar and the homepage's "Upcoming Talks & Events" box both update
from this file. Past events turn grey automatically based on today's date, so
there's no R script to run and no "scheduled" marker to remove.

### Add a publication

- **Journal article** → [`src/data/journal-articles.yaml`](src/data/journal-articles.yaml).
  Copy an existing entry and give it the next-highest `order` number.
  In `citation`, `{venue}` is replaced by the italicized journal name.
- **Everything else** (under review, working papers, chapters, policy memos,
  media, public writing) → [`src/data/other-publications.yaml`](src/data/other-publications.yaml).
  Each entry is one line of Markdown, with optional `notes` bullets:

  ```yaml
  - text: "[\"Paper Title.\"](https://link) (with Coauthor Name)"
    notes:
      - "Presented at the 2026 APSA"
  ```

  Put the newest item first in its section. To hide an item without deleting
  it, put `#` at the start of its lines.

The publications page search, the counts at the top, and the homepage's "New
Publications & Media" box all update automatically.

### Edit a text page or essay

Text pages are plain Markdown files in [`src/pages/`](src/pages). The file path
becomes the URL:

| File | URL |
| --- | --- |
| `src/pages/teaching/teaching.md` | `/teaching/teaching.html` |
| `src/pages/essays/haruki.md` | `/essays/haruki.html` |
| `src/pages/index.astro` | `/` (homepage) |

### Add a new essay

Create `src/pages/essays/my_essay.md`:

```md
---
layout: ../../layouts/Essay.astro
title: "My Essay Title"
author: "Jae Yeon Kim"
date: "October 16, 2026"
---

Your text in Markdown...
```

Then add a link to it in [`src/pages/essays/essays.md`](src/pages/essays/essays.md).
For non-essay pages, use `layout: ../../layouts/Page.astro`. The number of
`../` matches how deep the file is: one `../` per folder level below `src/`.

### Add an image, PDF, or slide deck

Put the file in [`public/`](public), for example `public/misc/photo.jpg` or
`public/slides/talk.pdf`. It's served from the site root: `/misc/photo.jpg`,
`/slides/talk.pdf`. Link to it with that path:

```md
![Caption](/misc/photo.jpg)
```

### Update the CV

Edit [`generate_cv/cv_Kim.tex`](generate_cv/cv_Kim.tex) and run
`./update_site.sh`. It compiles the PDF to `public/CV_Jae_Yeon_Kim.pdf` (the
navbar's CV link). Needs a LaTeX install (`latexmk`, `pdflatex`, or `tectonic`).

### Update coauthors or the maps

The community and personal page maps are drawn as SVG when the site builds, so
editing the data is all it takes:

- Coauthors: edit [`src/data/coauthors.csv`](src/data/coauthors.csv) (include
  Latitude/Longitude for a new affiliation). The coauthors page and the
  collaborator map both read it.
- Partners: edit [`src/data/partners.yaml`](src/data/partners.yaml).
- Places lived: edit [`src/data/places-lived.yaml`](src/data/places-lived.yaml).
- Talks map: add talks to `src/data/talks.yaml` as usual; `./update_site.sh`
  looks up coordinates for new cities (`npm run places`).

### Change the navbar, footer, colors, or fonts

- Navbar links, footer, site title, Google Analytics ID → [`src/site.ts`](src/site.ts)
- Colors, fonts, spacing → [`src/styles/global.scss`](src/styles/global.scss).
  Colors are CSS variables at the top: `:root` for light mode,
  `:root[data-theme='dark']` for dark mode. Change both.

---

## Quarto → Astro cheat sheet

| In Quarto you… | Here you… |
| --- | --- |
| `quarto preview` | `./preview.sh` |
| `quarto render` + commit `docs/` | `./update_site.sh` (GitHub builds the site for you) |
| Edited `_quarto.yml` for the navbar/footer | Edit `src/site.ts` |
| Edited `styles.scss` | Edit `src/styles/global.scss` |
| Wrote pages as `.qmd` | Write `.md`, with a `layout:` line in the frontmatter (see above) |
| Linked to `other.qmd` | Link to `other.html` |
| Added talks as hidden table rows in `index.qmd` | Add entries to `src/data/talks.yaml` |
| Ran `generate_calendar.R` | Nothing; it's automatic |
| Put images next to pages or in `misc/` | Put them in `public/` and link with `/misc/...` |
| Ran R code chunks inside a page | Run the R script yourself (in `r/`); save its output to `public/` |

Quarto's special Markdown doesn't work in `.md` files here. Use plain HTML
instead (put blank lines around Markdown inside HTML blocks):

| Quarto | Here |
| --- | --- |
| `::: {.book-entry}` … `:::` | `<div class="book-entry">` … `</div>` |
| `[Label]{.book-label}` | `<span class="book-label">Label</span>` |
| `::: {.callout-note}` … `:::` | `<div class="callout callout-note">` … `</div>` |
| `::: {.callout-note collapse="true"}` | `<details class="callout"><summary>Note</summary>` … `</details>` |
| `![Caption](img.png){width=60%}` | `<figure class="figure-center" style="width:60%"><img src="/misc/img.png" alt="Caption"><figcaption>Caption</figcaption></figure>` |
| `## Heading {.unnumbered}` | `## Heading` (headings are never numbered) |
| `::: {.reversed-list}` numbered list | `<div class="reversed-list">` … `</div>` (counts down automatically) |

Existing pages are full of examples. [`src/pages/book_projects/books.md`](src/pages/book_projects/books.md)
uses most of these.

---

## Project layout

```text
.
├── src/
│   ├── pages/          # one file per page; the path is the URL
│   ├── data/           # talks, publications, coauthors (YAML/CSV)
│   ├── components/     # navbar, footer, and React interactive parts
│   ├── layouts/        # page templates (Base, Page, Essay)
│   ├── lib/            # code that reads the data files
│   ├── styles/         # global.scss
│   └── site.ts         # navbar, footer, site-wide settings
├── public/             # images, PDFs, slides; copied to the site as-is
├── r/                  # R scripts that draw figures into public/misc/
├── generate_cv/        # LaTeX CV source and compile script
├── preview.sh          # preview locally
├── update_site.sh      # build, commit, push (GitHub deploys)
└── .github/workflows/deploy.yml
```

Interactive parts (React, in `src/components/`):

| Component | What it does |
| --- | --- |
| `PublicationsSearch.tsx` | Search box and filtering on the publications page |
| `motion/InView.tsx` | Fades the publications page's year groups in as you scroll; content stays visible if JavaScript fails |
| `TalksCalendar.tsx` | The talks calendar (FullCalendar) |
| `UpcomingTalks.tsx` | The homepage's upcoming-events box |
| `AgendaDialog.tsx` | The research-agenda diagram pop-up on the homepage |
| `ThemeToggle.tsx` | Dark/light switch |
| `SiteSearch.tsx` | Site-wide search (Pagefind; built by `npm run build`) |

---

## Troubleshooting

- **The build fails with a message about `talks.yaml`.** A date isn't in
  `YYYY-MM-DD` form, or `type` isn't one of `talk`, `panel`, `discussant`,
  `participant`. The message names the event.
- **The build fails with a YAML error.** Usually an unquoted value that
  contains `: ` or `"`. Wrap the whole value in double quotes and write any
  inner `"` as `\"`.
- **Site search shows nothing in `./preview.sh`.** Expected: search only works
  on a built site. Use `./preview.sh --built`.
- **A page in `./preview.sh` is missing its interactive parts** (for example,
  the publications page shows only the search box and counts). The live
  preview's cache went stale after a file change. Stop it with Ctrl+C, run
  `./preview.sh` again, and hard-refresh the page (Cmd+Shift+R).
- **A page changed but the live site didn't.** Check the **Actions** tab on
  GitHub; a red ✗ means the build failed, and its log shows why.
- **Type and template errors:** `npm run check`.
