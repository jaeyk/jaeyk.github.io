Configure or modify Quarto settings for this website — `_quarto.yml`, frontmatter options, rendering configuration, and project-level settings.

## Context

This site uses Quarto 1.8.27. All project-wide settings live in `_quarto.yml`. Per-page settings live in the YAML frontmatter of each `.qmd` file. Output goes to `docs/` for GitHub Pages.

## Instructions

### 1. `_quarto.yml` Structure

Top-level sections:

```yaml
project:
  type: website
  output-dir: docs
  preview:
    port: 5896

website:
  # Site metadata, navigation, search, analytics
  ...

format:
  html:
    # Global HTML rendering options
    ...
```

**Never change `output-dir: docs`** — GitHub Pages reads from there.

### 2. Adding a Page to Sidebar Navigation

Edit `_quarto.yml` under `website.sidebar.contents`:

```yaml
sidebar:
  style: docked
  search: true
  background: light
  contents:
    - text: "New Page"
      href: directory/filename.qmd
```

**Adding to an existing section:**
```yaml
- section: "Research"
  contents:
    - text: "Publications"
      href: publications/pubs.qmd
    - text: "New Subsection"    # <-- add here
      href: research/new.qmd
```

**Adding a divider:** `- text: "---"`

**Adding a new section:**
```yaml
- section: "New Section"
  contents:
    - text: "Page Name"
      href: path/page.qmd
```

### 3. Global HTML Options (under `format.html`)

Common options to add or modify:
```yaml
format:
  html:
    css: styles.css             # Custom CSS file
    toc: true                   # Enable TOC globally
    toc-depth: 4                # TOC heading depth
    toc-title: "Contents"       # TOC header label
    html-math-method: katex     # Math rendering engine
    highlight-style: github     # Code block syntax highlighting
    anchor-sections: true       # Clickable section anchors
    smooth-scroll: true         # Smooth scrolling to anchors
    include-in-header:          # Inject into <head> globally
      - text: '<script src="..."></script>'
```

### 4. Per-Page Frontmatter Options

Override global settings per page:
```yaml
---
title: "Page Title"
format:
  html:
    toc: false           # disable TOC for this page
    page-layout: full    # use full-width layout
    linestretch: 1.7     # line height
---
```

**Page layout options:**
- `article` — standard centered article (default)
- `full` — full viewport width
- `custom` — manual layout control

### 5. Website Metadata

In `_quarto.yml` under `website:`:
```yaml
website:
  title: "Hello, I'm Jae."
  description: "The personal website of Dr. Jae Yeon Kim"
  site-url: https://jaeyk.github.io/
  favicon: images/favicon/favicon-32x32.png
  repo-url: https://github.com/jaeyk/jaeyk.github.io
  google-analytics: G-Q5LW45FBCB   # DO NOT change
  back-to-top-navigation: true
  page-navigation: true
```

### 6. Search Configuration

```yaml
website:
  search:
    location: sidebar    # where the search box appears
    type: overlay        # how results display (overlay | textbox)
```

### 7. Page Footer

```yaml
website:
  page-footer:
    left: "Get in touch: jaekim@unc.edu"
    right:
      - icon: github
        href: https://github.com/jaeyk/jaeyk.github.io
      - icon: linkedin
        href: https://linkedin.com/in/...
```

### 8. Build Commands

```bash
quarto preview    # Local dev server on port 5896
quarto render     # Build entire site to docs/
quarto render path/to/file.qmd   # Render a single file
quarto check      # Verify Quarto installation
```

### 9. SCSS Theme Integration

The theme is set in `_quarto.yml`:
```yaml
format:
  html:
    theme:
      - cosmo            # Quarto base theme
      - styles.scss      # Site custom overrides
```

Edit `styles.scss` for theme customizations — never edit `styles.css` directly.

### 10. What NOT to Change

- `output-dir: docs` — required for GitHub Pages
- `google-analytics: G-Q5LW45FBCB` — existing analytics property
- `project.type: website` — changing breaks the build
- `preview.port: 5896` — team convention

Now help the user with: $ARGUMENTS
