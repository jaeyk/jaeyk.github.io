Create or update a Quarto Markdown (.qmd) page for this website following its established conventions.

## Context

This is a Quarto-based academic website (jaeyk.github.io). All content pages use `.qmd` files with YAML frontmatter.

## Instructions

When the user asks you to create or edit a markdown page, do the following:

1. **Use the correct frontmatter** based on the page type:

   **Standard page:**
   ```yaml
   ---
   title: "Title Here"
   format: html
   toc: true
   toc-depth: 4
   number-sections: false
   ---
   ```

   **Essay or article (with authorship):**
   ```yaml
   ---
   title: "Essay Title"
   author: "Jae Yeon Kim"
   date: "Month DD, YYYY"
   format: html
   toc: true
   number-sections: false
   ---
   ```

   **Data-driven page (loads a YAML data file):**
   ```yaml
   ---
   title: "Title"
   format: html
   resources:
     - data/filename.yml
   ---
   ```

2. **File naming:** Use snake_case with `.qmd` extension (e.g., `new_essay.qmd`, `spring_teaching.qmd`)

3. **Place the file** in the appropriate subdirectory:
   - Personal essays → `essays/`
   - Teaching content → `teaching/`
   - Research/publications → `publications/`
   - Community work → `community_building/`
   - Software → `software/`
   - Datasets → `datasets/`
   - Talks → `talks/`
   - Awards → `awards/`

4. **Content formatting rules:**
   - Use `##` for top-level sections (H2), `###` for subsections
   - Bold with `**text**`, italic with `*text*`
   - For images: `![Alt text](path){fig-align="center" width="80%"}`
   - For links: `[label](url)`
   - Ordered lists use `1.` — Quarto will auto-number
   - For reversed/descending numbered lists, wrap in `<div class="reversed-list">` and use `<ol>`

5. **After creating the file**, remind the user to add it to the sidebar in `_quarto.yml` if it should appear in navigation:
   ```yaml
   - text: "Display Name"
     href: directory/filename.qmd
   ```

6. **Run `quarto preview`** to verify locally before rendering.

Now help the user with: $ARGUMENTS
