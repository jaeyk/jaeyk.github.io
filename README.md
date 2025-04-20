# jaeyk.github.io

This repository contains the source files for [Jae Yeon Kim](https://jaeyk.github.io)'s academic homepage, built using [Quarto](https://quarto.org/) and published via GitHub Pages.

## 🧭 About

The website serves as the personal academic homepage of Dr. Jae Yeon Kim, Assistant Research Scientist at the SNF Agora Institute at Johns Hopkins University and incoming Assistant Professor of Public Policy at the University of North Carolina–Chapel Hill (starting January 2026).

It includes:
- Professional biography and affiliations
- CV and publication list
- Details on ongoing research projects and software
- Teaching and community engagement
- Speaking engagements and recent news

## 🚀 Live Site

Visit the live site at: [https://jaeyk.github.io](https://jaeyk.github.io)

## 🛠️ Technology Stack

- [Quarto](https://quarto.org/) for rendering Markdown/HTML pages
- GitHub Pages for static site hosting
- Custom SCSS for styling (see `styles.scss`)
- [Ubuntu](https://fonts.google.com/specimen/Ubuntu) font via Google Fonts

## 🗂️ Key Files and Directories

- `index.qmd`: Homepage content
- `_quarto.yml`: Global configuration and site metadata
- `styles.scss`: Custom styling for institutional color themes and typography
- `CV_Jae_Yeon_Kim.pdf`: Up-to-date academic CV
- `talks/`, `awards/`, `publications/`, etc.: Section pages
- `docs/`: Rendered output for GitHub Pages (auto-generated)

## 🎨 Styling Notes

Institution names are color-coded to match their official branding. Styles are defined in `styles.scss`, including:
- `.jhu-blue`, `.harvard-crimson`, `.georgetown-blue`, `.michigan-blue`, `.carolina-blue`, `.berkeley-blue`, `.cfa-blue`, etc.

To apply a style, use inline HTML in `.qmd` files like:

```html
<span class="carolina-blue">University of North Carolina–Chapel Hill</span>
