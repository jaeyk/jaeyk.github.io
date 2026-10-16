Add or modify styles for this Astro website by editing `src/styles/global.scss`.

## Context

All site styles live in one SCSS file, `src/styles/global.scss`, imported by `src/layouts/Base.astro`. Astro compiles it at build time (the `sass` package), so there's no separate compile step. There is no Bootstrap: this file supplies the base typography, layout, navbar, footer, and every component style.

**Palette and fonts** (SCSS variables at the top):
- `$unc-blue: #4b9cd3` (Carolina Blue), `$unc-dark-blue: #13294b`
- `$font-serif` (Source Serif 4) for headings, quotes, and diagram labels; `$font-sans` (Inter) for body text and UI
- `$prose-width: 80ch` (essay line length), `$page-width: 1400px`

**Colors and dark mode:** never hard-code a color in a new rule. Use the CSS variables (`--site-text`, `--site-link`, `--site-link-hover`, `--site-heading`, `--site-muted`, `--site-accent`, `--site-bg`, `--site-surface`, `--site-surface-2`, `--site-border`, `--site-border-soft`, `--site-line`, `--site-label-bg`, `--site-label-text`, `--site-callout-header`, …). Each has a light value on `:root` and a dark value on `:root[data-theme='dark']`. A new variable must be added to **both** blocks. The theme is set by the `data-theme` attribute on `<html>` (dark by default; `ThemeToggle.tsx` switches it).

**Line length:** essays (layout `Essay.astro`) get `body.prose`, which caps paragraphs at `$prose-width`. Other pages use the full content width.

## Instructions

1. **Find the right section.** The file is organized by banner comments: Color tokens, Base, Layout, Links, Quotes, Figures, Tables, Forms, Navbar, Footer, Dialogs, Utility classes (callouts, book cards, badges, reversed lists), Details, Publications page, Talks page, Homepage, Research agenda diagram, Mobile. Add rules to the matching section.

2. **Reuse before adding.** Existing utility classes:
   - `.callout`, `.callout-note`, `.callout-simple`, `.callout-header`, `details.callout`
   - `.book-entry`, `.book-label`
   - `.figure-center`, `.table-wrap`, `.muted`
   - `.reversed-list` (CSS counter, sized by a script in `Base.astro`)
   - `.carolina-blue` (highlight label)
   - `.badge .badge-talk|panel|discussant|participant|lecture|workshop|podcast|moderator|award`

3. **Write new rules** with variables and SCSS nesting:
   ```scss
   .new-class {
     padding: 0.5rem 1rem;
     border: 1px solid var(--site-border);
     border-radius: 6px;
     background: var(--site-surface);
     color: var(--site-heading);
   }
   ```

4. **Mobile:** breakpoints in use are `max-width: 768px` (phones; general mobile block at the end of the file), `900px` (homepage sidebar stacks), and `991.98px` (navbar collapses to the hamburger). Put phone overrides in the existing mobile block.

5. **Talks calendar (FullCalendar) caveat:** FullCalendar draws with `<table>`s, so generic table rules use `:not(.fc *)` to skip it. Keep that on any new table rule. Style the calendar through `.talks-calendar …` and the `--fc-*` variables in `:root`.

6. **Component-scoped styles:** an `.astro` file can have its own `<style>` block (scoped automatically). Prefer `global.scss` for anything reused, and for styling React components.

7. **Check both themes:** `./preview.sh`, then use the sun/moon toggle in the navbar to look at the change in light and dark mode.
