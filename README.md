# jaeyk.github.io

This repository contains the source files for [Jae Yeon Kim](https://jaeyk.github.io)'s academic homepage, built using [Quarto](https://quarto.org/) and published via GitHub Pages.

## About

The website serves as the personal academic homepage of Jae Yeon Kim, Assistant Professor of Public Policy at the University of North Carolina at Chapel Hill.

It includes:
- Professional biography and affiliations
- CV and publication list
- Book projects and ongoing research
- Software and datasets
- Teaching and community engagement
- Speaking engagements and news

## Live Site

Visit the live site at: [https://jaeyk.github.io](https://jaeyk.github.io)

## Technology Stack

- [Quarto](https://quarto.org/) for rendering Markdown/HTML pages
- GitHub Pages for static site hosting
- Custom SCSS for styling with UNC color theme (see `styles.scss`)
- Typography via Google Fonts:
  - [Source Serif 4](https://fonts.google.com/specimen/Source+Serif+4) for body text and headings
  - [Inter](https://fonts.google.com/specimen/Inter) for sidebar navigation
- Bootstrap Icons for UI elements

## Site Structure

The site uses a **left sidebar navigation** with the following sections:

| Section | Directory | Description |
|---------|-----------|-------------|
| Home | `index.qmd` | Main landing page with bio and news |
| CV | `CV_Jae_Yeon_Kim.pdf` | Academic CV |
| Publications | `publications/` | Research publications |
| Book | `book_projects/` | Book project details |
| Talks | `talks/` | Speaking engagements |
| Awards | `awards/` | Honors and awards |
| Software | `software/` | Open-source tools and packages |
| Data | `datasets/` | Published datasets |
| Teaching | `teaching/` | Courses and advising |
| Community | `community_building/` | Community engagement |
| Personal | `essays/` | Personal essays |
| Office Hour | `office_hour/` | Office hour policies |

## Key Files

- `_quarto.yml` - Global configuration, sidebar navigation, and site metadata
- `index.qmd` - Homepage content
- `styles.scss` - Custom styling (UNC colors, typography, sidebar styles)
- `docs/` - Rendered output for GitHub Pages (auto-generated)

## Local Development

To preview the site locally:

```bash
quarto preview
```

To render the site:

```bash
quarto render
```

The rendered files are output to the `docs/` directory, which is served by GitHub Pages.

## Recent Content Updates (February 2026)

- Added event/teaching photos at the bottom of:
  - `talks/talks.qmd`
  - `teaching/teaching.qmd`
  - `community_building/community.qmd`
  - `essays/essays.qmd`
- Standardized display style for page photos:
  - Center aligned (`fig-align="center"` or centered `<figure>`)
  - Reduced size (`width="60%"` by default; smaller where needed, e.g., `45%` on essays page)
- Updated the Office Hour map embed (`office_hour/office_hour.qmd`) to be responsive with `width="100%"`.
- Fixed Quarto structure warning in `talks/talks.qmd` by closing an unclosed `:::{.cell}` block.
