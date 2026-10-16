Create or update a Markdown (.md) content page on this Astro website following its established conventions.

## Context

Text pages (essays, teaching, awards, books, software, data, …) are plain Markdown files in `src/pages/`. The file path is the URL: `src/pages/teaching/teaching.md` → `/teaching/teaching.html`. Pages that need data or components are `.astro` files instead (see `/html` and `/javascript`).

## Instructions

1. **Choose the layout by page type.** The number of `../` is one per folder level below `src/`.

   Text page:
   ```yaml
   ---
   layout: ../../layouts/Page.astro
   title: "Page Title"
   ---
   ```

   Essay (line length capped for reading; author and date shown under the title):
   ```yaml
   ---
   layout: ../../layouts/Essay.astro
   title: "Essay Title"
   author: "Jae Yeon Kim"
   date: "Month DD, YYYY"
   ---
   ```

   Omit `title` to have no page heading (as `essays/essays.md` does).

2. **File names are snake_case**, placed in the matching folder (`src/pages/essays/my_essay.md`).

3. **Link new pages from somewhere.** A new essay goes in the right category list in `src/pages/essays/essays.md`. A new top-level section goes in `NAV` in `src/site.ts`.

4. **Links:** internal links point to `.html` (`[essay](return2academia.html)`, `/talks/talks.html`). Never link to `.qmd` or `.md`.

5. **Images and files** live in `public/` and use root paths: `![Caption](/misc/photo.jpg)`, `[slides](/slides/talk.pdf)`.

6. **No Quarto syntax.** Use HTML for anything beyond plain Markdown, with blank lines between HTML tags and Markdown inside them:

   | Want | Write |
   | --- | --- |
   | Card / styled block | `<div class="book-entry">` … `</div>` |
   | Small label | `<span class="book-label">Label</span>` |
   | Note box | `<div class="callout callout-note">` … `</div>` (`callout-simple` for a plain bar) |
   | Collapsible note | `<details class="callout"><summary>Note</summary>` … `</details>` |
   | Collapsible section | `<details>` + `<summary><strong>Title</strong></summary>` |
   | Centered figure | `<figure class="figure-center" style="width:60%"><img src="/misc/x.png" alt="…"><figcaption>…</figcaption></figure>` |
   | Count-down numbered list | `<div class="reversed-list">` + a Markdown `1.` list + `</div>` |
   | Icon | `<i class="bi bi-envelope"></i>` (Bootstrap Icons are loaded site-wide) |

7. **Talks and publications are not Markdown pages.** Edit `src/data/talks.yaml`, `src/data/journal-articles.yaml`, or `src/data/other-publications.yaml` (schemas in the root `README.md` and the `website_builder` agent).

8. **Check it:** `./preview.sh`, open the page, then confirm `npm run build` passes.
