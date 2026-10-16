Add or modify HTML on this Astro website — inside Markdown pages, in `.astro` pages and components, or on the homepage — following its established patterns and CSS classes.

## Context

- **Markdown pages** (`src/pages/**/*.md`) accept raw HTML. Put a blank line between an HTML tag and any Markdown inside it, or the Markdown won't be processed.
- **`.astro` files** (`src/pages/index.astro`, `pubs.astro`, `talks.astro`, `coauthors.astro`, `src/layouts/*`, `src/components/*.astro`) are HTML templates with a `---` frontmatter script on top. Use `class` (not `className`), `{expression}` to insert values, and `{items.map((x) => <li>{x}</li>)}` for lists.
- **The homepage** (`src/pages/index.astro`) is hand-written HTML: hero, floated `.landing-sidebar` (profile, links, upcoming talks, new publications), bio paragraphs, and the student-note callout.

## Instructions

1. **Use existing classes** (defined in `src/styles/global.scss`):
   - `.callout callout-note` (+ `.callout-header` / `.callout-body`, or `callout-simple`); `<details class="callout"><summary>Note</summary>…</details>` for collapsible notes
   - `.book-entry` cards with a `.book-label` span
   - `<figure class="figure-center">` with `<img>` + `<figcaption>`
   - `<details>` + `<summary><strong>Title</strong></summary>` for collapsible sections
   - `.reversed-list` wrapping an `<ol>` for count-down numbering
   - `.table-wrap` around wide tables
   - `.badge .badge-<type>`, `.carolina-blue`, `.muted`
   - Homepage: `.landing-box` (sidebar boxes), `.landing-box-link`, `.hello`

2. **No inline colors.** Use classes or `var(--site-…)` so dark mode works. Layout-only inline styles (width, gap, margin) are fine.

3. **Icons:** Bootstrap Icons are loaded site-wide: `<i class="bi bi-envelope" aria-hidden="true"></i>`. Add `aria-hidden="true"` to decorative icons and give icon-only links an `aria-label`.

4. **Links and assets:** internal pages end in `.html` (`/talks/talks.html`). Files in `public/` use root paths (`/misc/photo.jpg`). External embeds (`<iframe>`) are fine; give them a `title`.

5. **Interactive HTML** (state, toggles, dialogs) belongs in a React component, not inline `<script>`; see `/javascript`.

6. **Whitespace:** `compressHTML` is off in `astro.config.mjs` because compression removes the spaces next to inline links. Leave it off.

7. **Check:** `./preview.sh`, view the page at desktop width and narrow (phone) width, in both themes.
