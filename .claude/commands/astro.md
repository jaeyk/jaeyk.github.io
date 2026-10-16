Configure or modify Astro settings for this website — `astro.config.mjs`, site-wide settings in `src/site.ts`, layouts, page routing, and integrations.

## Context

The site is Astro (static output) with the React and sitemap integrations, plus Pagefind run after the build for site search. Project-level settings are split across:

| File | Holds |
| --- | --- |
| `astro.config.mjs` | `site` URL, integrations (`react()`, `sitemap()`), `build.format: 'file'`, `compressHTML: false` |
| `src/site.ts` | `SITE_TITLE`, `SITE_DESCRIPTION`, `GOOGLE_ANALYTICS_ID`, `EMAIL`, `NAV` (navbar), `FOOTER_LINKS` |
| `src/layouts/Base.astro` | `<head>` (fonts, Bootstrap Icons, favicons, Open Graph/Twitter meta, GA, theme script), navbar, `<main data-pagefind-body>`, footer |
| `src/layouts/Page.astro` | Page title block; used by Markdown pages via `layout:` |
| `src/layouts/Essay.astro` | `Page` + `prose` line-length cap + author/date meta |
| `package.json` | Scripts: `dev`, `build` (`astro build && pagefind --site dist`), `preview`, `check` |
| `tsconfig.json` | Strict TS, React JSX; excludes `dist`, `public`, `node_modules` |

## Instructions

1. **Navbar / footer / site title:** edit `src/site.ts`. Navbar `href`s must end in `.html` (or point to a file such as the CV PDF).

2. **URLs:** `build.format: 'file'` makes `src/pages/a/b.md` build to `/a/b.html`, matching the old Quarto URLs. Don't change it or rename page files without a reason, since that breaks inbound links.

3. **Page-level options** live in frontmatter: `layout`, `title`, `author`, `date`, `description` (meta description). `.astro` pages pass `title` (and optional `bodyClass`) to `Page`/`Base` as props.

4. **Head tags for every page** (meta, fonts, scripts) go in `Base.astro`. For one page only, add a prop to `Base`, or a `<slot>` for head content.

5. **Search indexing:** Pagefind indexes only `<main data-pagefind-body>`. Exclude an element with `data-pagefind-ignore`. Search works only on a built site (`./preview.sh --built`).

6. **Integrations:** add them with `npx astro add <name>`, or install and register them in `astro.config.mjs`. Astro here is v7. Check https://docs.astro.build before relying on memory for APIs that may have changed.

7. **Markdown processing:** Astro's defaults (GitHub-flavored Markdown, smart quotes). Raw HTML is allowed in `.md`. Remark/rehype plugins would go under `markdown:` in `astro.config.mjs`.

8. **Verify every config change** with `npm run check` and `npm run build`, then `./preview.sh --built`.
