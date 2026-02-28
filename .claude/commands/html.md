Add or modify HTML elements within a .qmd page on this Quarto website, following its established HTML patterns and CSS conventions.

## Context

This site mixes HTML directly into `.qmd` Quarto Markdown files. It uses Bootstrap (via Quarto), custom SCSS variables, and specific CSS utility classes. All HTML should integrate with the existing theme.

## Instructions

When the user asks you to add or modify HTML on a page, follow these rules:

### 1. Available CSS Utility Classes

| Class | Effect |
|---|---|
| `.carolina-blue` | UNC blue badge highlight (background #e8edf7, blue text, rounded padding) |
| `.reversed-list` | Wrapper for reversed-numbered `<ol>` lists |
| `.hero-header` | Homepage hero section layout |

**Example — `.carolina-blue` badge:**
```html
<span class="carolina-blue">Featured</span>
```

**Example — Reversed list (publications/software):**
```html
<div class="reversed-list">
<ol>
<li>Item 3 (displays as 3, 2, 1...)</li>
<li>Item 2</li>
<li>Item 1</li>
</ol>
</div>
```
Note: The counter reset value is auto-calculated by the site's JavaScript — just use the class.

### 2. Bootstrap Icons

The site loads Bootstrap Icons. Use them as:
```html
<i class="bi bi-envelope"></i>       <!-- email -->
<i class="bi bi-github"></i>         <!-- GitHub -->
<i class="bi bi-linkedin"></i>       <!-- LinkedIn -->
<i class="bi bi-file-earmark-pdf"></i> <!-- PDF -->
<i class="bi bi-box-arrow-up-right"></i> <!-- external link -->
```

### 3. Expandable Sections

```html
<details open>
<summary><strong>Section Title</strong></summary>

Markdown or HTML content here.

</details>
```
Use `open` attribute for sections that should be expanded by default.

### 4. Layout Divs

```html
<!-- Two-column layout using Bootstrap grid -->
<div class="row">
  <div class="col-md-6">Left content</div>
  <div class="col-md-6">Right content</div>
</div>

<!-- Centered content -->
<div style="text-align: center;">Content here</div>

<!-- Custom card/box -->
<div style="background: #f8f9fa; padding: 1.5rem; border-radius: 8px; margin: 1rem 0;">
Content here
</div>
```

### 5. Image Figures

Prefer the Quarto markdown syntax for images (Quarto handles responsive rendering):
```markdown
![Caption](path/to/image.png){fig-align="center" width="80%"}
```

For HTML-only contexts:
```html
<figure style="text-align: center;">
  <img src="path/to/image.png" alt="Description" style="width: 80%;">
  <figcaption>Caption text</figcaption>
</figure>
```

### 6. Links & Buttons

```html
<!-- Standard link button -->
<a href="https://..." class="btn btn-sm btn-outline-primary" target="_blank">
  <i class="bi bi-box-arrow-up-right"></i> Label
</a>

<!-- UNC-themed inline link -->
<a href="https://..." style="color: #4B9CD3;">Link text</a>
```

### 7. Color Reference

| Variable | Hex | Use |
|---|---|---|
| UNC Carolina Blue | `#4B9CD3` | Primary accent, links |
| UNC Dark Blue | `#13294B` | Dark backgrounds, headers |
| UNC Gray | `#E0E0E0` | Borders, backgrounds |
| Badge background | `#e8edf7` | `.carolina-blue` bg |

### 8. Typography Rules

- Body/headings font: Source Serif 4 (serif) — Quarto applies automatically
- UI/sidebar font: Inter (sans-serif) — apply with `style="font-family: 'Inter', sans-serif;"`
- Heading weights use `font-weight: 600`

### 9. What NOT to Do

- Do not add inline `<style>` blocks to individual pages — add to `styles.scss` instead
- Do not use `<table>` for layout — use Bootstrap grid
- Do not override Quarto's default heading hierarchy
- Do not hardcode font imports — they are loaded globally

Now help the user with: $ARGUMENTS
