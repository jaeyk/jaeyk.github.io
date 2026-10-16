Add or modify interactive behavior on this Astro website: React components (islands) for anything stateful, and small Astro `<script>`s for simple DOM tweaks.

## Context

Pages are static HTML. Interactivity comes from React components in `src/components/*.tsx`, mounted as "islands" with a `client:*` directive:

| Component | Used in | Directive | Purpose |
| --- | --- | --- | --- |
| `PublicationsSearch.tsx` | `publications/pubs.astro` | `client:load` | Search/filter, counts, grouped and numbered lists |
| `TalksCalendar.tsx` | `talks/talks.astro` | `client:only="react"` | FullCalendar v6 (month grid on desktop, list on phones) |
| `UpcomingTalks.tsx` | `index.astro` | `client:load` | Next 5 events, recomputed from the visitor's date |
| `AgendaDialog.tsx` | `index.astro` | `client:visible` | Inline link + research-agenda `<dialog>` (portaled to `<body>`) |
| `ThemeToggle.tsx` | `Navbar.astro` | `client:load` | Dark/light switch (`data-theme` on `<html>`, `localStorage.theme`) |
| `SiteSearch.tsx` | `Navbar.astro` | `client:idle` | Pagefind search dialog (⌘K); loads `/pagefind/*` lazily |

Data reaches components as props from the page's frontmatter (`loadTalks()`, `loadJournalArticles()`, `loadOtherSections()` in `src/lib/`). Props must be serializable (plain objects, strings, numbers).

## Instructions

1. **Pick the right tool.**
   - State, user input, or re-rendering → React component in `src/components/`, written in TypeScript (`.tsx`).
   - A one-off DOM tweak with no state → a `<script>` tag in an `.astro` file. Astro bundles it as a module that runs once per page, so no `DOMContentLoaded` wrapper is needed (see the navbar toggle in `Navbar.astro` and the `.reversed-list` sizer in `Base.astro`).
   - Don't put `<script>` tags in Markdown pages.

2. **Choose the hydration directive:** `client:load` (needed right away), `client:idle` (can wait), `client:visible` (below the fold), `client:only="react"` (uses `window` or the DOM at render time; it isn't rendered at build time, so it can't be used for content that should be in the HTML for SEO).

3. **Write components like the existing ones:**
   - Default-export a function component and type its props with an `interface`.
   - Import React types by name (`import { useState, type ReactNode } from 'react'`), not as `React.X`.
   - Touch `window`, `document`, or `localStorage` only inside `useEffect`/event handlers, unless the island is `client:only`. Wrap `localStorage` in try/catch.
   - For anything date-dependent, render with a build-time value, then recompute in `useEffect` (see `UpcomingTalks.tsx`) so the page never goes stale.
   - Style with classes from `src/styles/global.scss` (`className=…`), not inline colors.

4. **Libraries:** install with `npm install <pkg>` and import them; don't load scripts from a CDN. FullCalendar is pinned to v6 (`@fullcalendar/*@6`), and its v7 React package is a different major API. js-yaml is v5: use `import { load } from 'js-yaml'` (there is no default export).

5. **Shared logic** (parsing, date math) belongs in `src/lib/` so pages and components can both import it.

6. **Analytics:** the Google Analytics tag is in `Base.astro`. Don't add another.

7. **Verify:** `npm run check` (types), `npm run build`, then `./preview.sh --built` and use the feature in the browser with the devtools console open (no errors).
