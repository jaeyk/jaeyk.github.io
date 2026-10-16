Run shell commands and scripts for previewing, building, deploying, and maintaining this Astro website.

## Context

The repo (`/Users/jaeyeonkim/Documents/jaeyk.github.io/`) is an Astro project at its root. It needs Node.js 22+ (`package.json` `engines`). R scripts in `r/` draw figures, and LaTeX in `generate_cv/` builds the CV. GitHub Actions deploys on every push to `main`.

## Instructions

### 1. Preview

```bash
./preview.sh            # live dev server, http://localhost:4321, reloads on save (no site search)
./preview.sh --built    # production build + preview server, includes Pagefind search
```

Both install dependencies (`npm ci`) on first run. Run long-lived servers in the background, and stop them when done (`npx astro preview stop`, or kill the dev server).

### 2. Build and check

```bash
npm run build    # astro build → dist/, then pagefind --site dist
npm run check    # astro check: TypeScript + .astro template errors
```

A failing build blocks deploys, so run it before pushing. Data errors (bad talk dates or types, malformed YAML) fail the build with a message naming the entry.

### 3. Deploy

```bash
./update_site.sh                  # CV if changed → R maps → build → git add -A, commit, push
./update_site.sh --skip-maps      # skip the R map scripts
./update_site.sh --force-cv       # recompile the CV regardless
./update_site.sh -m "message"     # custom commit message
```

The push to `main` triggers `.github/workflows/deploy.yml` (Node 22 → `npm ci` → `npm run build` → publish `dist/` to `gh-pages`). Watch it with:

```bash
gh run list --limit 3
gh run watch <run-id> --exit-status
```

Only commit or push when the user asks. `update_site.sh` stages everything with `git add -A`, so check `git status` first.

### 4. CV

```bash
UPDATE_SITE_SKIP_RECURSE=1 UPDATE_SITE_SKIP_GIT=1 ./generate_cv/compile_cv.sh
```

This compiles `generate_cv/cv_Kim.tex` and copies the result to `public/CV_Jae_Yeon_Kim.pdf`. Without the two variables, the script also runs `update_site.sh` and commits/pushes. It needs `latexmk`, `pdflatex`, or `tectonic`.

### 5. R figures

```bash
Rscript r/coauthor_map.R      # reads src/data/coauthors.csv → public/misc/coauthor_map.{png,html}
Rscript r/partner_map.R       # → public/misc/partner_map.{png,html}
Rscript r/life_story_map.R    # → public/misc/life_story_map.png
Rscript r/diagram.R           # → public/misc/research_agenda_slide_horizontal_wrapped.png
```

The scripts use `here()`, which finds the root via `jaeyk.Rproj`. Run them from the repo root.

### 6. Dependencies

```bash
npm ci                          # clean install from package-lock.json (what CI uses)
npm install <pkg>               # add a dependency; commit package.json and package-lock.json
npm outdated                    # see available updates
```

Keep FullCalendar on v6 (`@fullcalendar/*@6`) unless deliberately migrating.

### 7. Don't

- Don't commit `dist/`, `node_modules/`, or `.astro/` (all gitignored).
- Don't recreate `docs/` or run `quarto`; the site no longer uses Quarto.
