Run shell commands and scripts for building, previewing, and maintaining this Quarto website.

## Context

This is a Quarto-based academic website. The main build tool is `quarto`. R scripts generate visualizations. GitHub Pages serves from the `docs/` directory. The repo is at `/Users/jaeyeonkim/Documents/jaeyk.github.io/`.

## Instructions

### 1. Core Quarto Commands

```bash
# Start local dev server (port 5896, auto-reloads on changes)
quarto preview

# Build entire site to docs/
quarto render

# Build a single page only
quarto render path/to/file.qmd

# Check Quarto installation and version
quarto check

# Update Quarto extensions
quarto update
```

Always run commands from the project root: `/Users/jaeyeonkim/Documents/jaeyk.github.io/`

### 2. Typical Workflow

```bash
# 1. Start preview while editing
quarto preview

# 2. Make edits to .qmd or .scss files

# 3. When ready to publish, render the full site
quarto render

# 4. Stage and commit the docs/ output
git add docs/
git add -p    # review changes
git commit -m "Update site YYYY-MM-DD HH:MM"
git push
```

### 3. Git Operations

```bash
# Check status (never -uall flag — can be slow on large repos)
git status

# Stage specific files
git add index.qmd essays/new_essay.qmd

# Stage built output
git add docs/

# Commit
git commit -m "Message here"

# Push to GitHub Pages
git push origin main
```

The site auto-deploys when `docs/` is pushed to `main`.

### 4. R Scripts for Visualizations

Some pages use R-generated figures. Run R scripts individually:
```bash
Rscript figures/career_gantt_chart.R
Rscript community_building/coauthor_map.R
Rscript community_building/partner_map.R
Rscript essays/life_story_map.R
```

Or render with R inline via Quarto (if the `.qmd` file has R code chunks):
```bash
quarto render publications/pubs.qmd
```

### 5. Checking Site Output

```bash
# List generated HTML files in docs/
ls docs/*.html

# Check file sizes (find large assets)
du -sh docs/site_libs/
du -sh docs/

# Find recently modified source files
find . -name "*.qmd" -newer docs/index.html -not -path "./docs/*"
```

### 6. Cleaning & Rebuilding

```bash
# Remove generated output and rebuild fresh
rm -rf docs/
quarto render

# Clear Quarto cache (if rendering behaves oddly)
rm -rf .quarto/
quarto render
```

**Warning:** `rm -rf docs/` removes all built files. Always re-run `quarto render` immediately after.

### 7. Debugging Build Issues

```bash
# Verbose render output
quarto render --verbose

# Render single file with verbose logging
quarto render path/to/file.qmd --verbose

# Check if SCSS compiles without errors
quarto render index.qmd

# Validate _quarto.yml syntax
quarto check
```

### 8. Dependency Management

```bash
# Check R packages (run inside R or Rscript)
Rscript -e "installed.packages()[,1]"

# Install R package if missing
Rscript -e "install.packages('packagename')"
```

### 9. Common File Locations

| Purpose | Path |
|---|---|
| Main config | `_quarto.yml` |
| Homepage | `index.qmd` |
| Styles source | `styles.scss` |
| Styles output | `styles.css` |
| Built site | `docs/` |
| Quarto cache | `.quarto/` |
| GitHub Actions | `.github/workflows/` |

### 10. What NOT to Do

- Do not `rm -rf docs/` without immediately running `quarto render`
- Do not force-push to `main` — it can break GitHub Pages
- Do not edit files inside `docs/` — they are overwritten by `quarto render`
- Do not run `quarto render` with `--no-cache` unnecessarily on large sites

Now help the user with: $ARGUMENTS
