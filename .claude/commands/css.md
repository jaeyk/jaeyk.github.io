Add or modify styles for this Quarto website by editing `styles.scss`. Never edit `styles.css` directly — it is the compiled output.

## Context

The site uses Bootstrap (via Quarto's `default` theme, with a light/dark toggle) extended with custom SCSS in `styles.scss`. `styles.scss` is compiled to `styles.css` with `sass styles.scss styles.css --no-source-map` (`update_site.sh` does this), then loaded via `css: styles.css`. Dark-mode Bootstrap colors live in `theme-dark.scss`.

**Colors and dark mode:** never hard-code a color in a new rule. Use the CSS variables defined at the top of the rules section (`--site-link`, `--site-link-hover`, `--site-heading`, `--site-muted`, `--site-accent`, `--site-bg`, `--site-surface`, `--site-surface-2`, `--site-border`, `--site-border-soft`, `--site-line`, …). Each has a light value on `:root` and a dark value on `body.quarto-dark`; add a new variable to both blocks if needed.

**Line length:** pages in `essays/` get `body-classes: prose` (from `essays/_metadata.yml`), which caps paragraphs at `$prose-width`. Other pages use the full 1400px content width. To cap another long-form page, add `body-classes: prose` to its frontmatter.

## Instructions

### 1. File to Edit

**Always edit:** `styles.scss` (root level)
**Never edit:** `styles.css` — overwritten by `quarto render`
**Supplementary:** `css/main.scss` — additional rules (check before duplicating)

### 2. SCSS File Structure

`styles.scss` is divided into Quarto SCSS sections:
```scss
/*-- scss:defaults --*/
// Variables (override Bootstrap defaults)

/*-- scss:rules --*/
// Custom CSS rules
```

Always place variables in `defaults`, and rules in `rules`.

### 3. Existing SCSS Variables

```scss
// Color palette
$unc-blue: #4B9CD3;          // UNC Carolina Blue — primary accent
$unc-dark-blue: #13294B;     // UNC Dark Blue — dark backgrounds
$unc-white: #FFFFFF;
$unc-gray: #E0E0E0;          // Borders and subtle backgrounds

$primary-color: $unc-blue;
$primary-color-dark: $unc-dark-blue;
$secondary-color: $unc-gray;

// Typography
$font-serif: 'Source Serif 4', Georgia, Times, 'Times New Roman', serif;
$font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;

$headings-font-family: $font-serif;
$sidebar-font-family: $font-sans;
$font-family-base: $font-sans;   // Inter body text; Source Serif for headings and quotes
```

### 4. Existing CSS Utility Classes

**`.carolina-blue` — highlight label (the only inline highlight class):**
```scss
.carolina-blue {
  color: var(--site-label-text);
  background-color: var(--site-label-bg);
  padding: 1px 5px;
  border-radius: 4px;
  font-weight: 600;
}
```

**`.badge .badge-<type>` — event-type badges** (talk, panel, discussant, participant, lecture, workshop, podcast, moderator, award). Colors match the talks calendar palette in `generate_calendar.R`.

**`.reversed-list` — descending counter list:**
```scss
.reversed-list {
  ol {
    list-style: none;
    counter-reset: reversed-counter var(--reversed-counter-reset, 100);
    li::before {
      content: counter(reversed-counter) ". ";
      counter-increment: reversed-counter -1;
    }
  }
}
```

### 5. Heading Styles

```scss
/*-- scss:rules --*/
h1, h2, h3 {
  font-family: $headings-font-family;
  font-weight: 600;
}
```

To add a new heading style, extend this block or add a new rule below it.

### 6. Adding a New Utility Class

Add under `/*-- scss:rules --*/`:
```scss
.your-class-name {
  // properties
}
```

Example — a highlighted callout box:
```scss
.callout-box {
  background-color: lighten($unc-blue, 40%);
  border-left: 4px solid $unc-blue;
  padding: 1rem 1.25rem;
  border-radius: 4px;
  margin: 1.5rem 0;
}
```

### 7. Targeting Quarto Elements

Common Quarto-generated selectors:
```scss
// The site has no sidebar, and the TOC/margin sidebar is hidden site-wide.

// Content area
.quarto-title { }
.quarto-title-meta { }
#quarto-content { }

// Footer
.nav-footer { }

// Search
#quarto-search { }
```

### 8. Responsive Design

Use Bootstrap breakpoints (already available):
```scss
// Mobile-first
@include media-breakpoint-down(md) {
  .your-class {
    font-size: 0.9rem;
  }
}

@include media-breakpoint-up(lg) {
  .your-class {
    font-size: 1.1rem;
  }
}
```

Breakpoints: `xs` (0), `sm` (576px), `md` (768px), `lg` (992px), `xl` (1200px)

### 9. Typography Reference

| Element | Font | Weight |
|---|---|---|
| Body text, navbar, footer | Inter | 400 |
| Blockquotes | Source Serif 4 italic | 400 |
| Headings (H1–H3) | Source Serif 4 | 600 |
| UI labels (homepage boxes, diagram) | Inter | 600/700 |
| Code blocks | Monospace (system) | 400 |

### 10. Color Quick Reference

| Name | Hex | Use |
|---|---|---|
| Carolina Blue | `#4B9CD3` | Link hover, accents (`--site-link-hover`) |
| Dark Blue | `#13294B` | Links, headings (`--site-link`, `--site-heading`) |
| Rose | `#c43f5c` | Small-caps section labels (`--site-accent`) |
| Label BG | `#e8edf7` | `.carolina-blue` background (`--site-label-bg`) |
| Border | `#d9e2ec` | Card and box borders (`--site-border`) |

Use the variable, not the hex value, so dark mode keeps working.

### 11. After Editing

Run `sass styles.scss styles.css --no-source-map`, then `quarto render`. Check both light and dark mode with `quarto preview` (toggle in the navbar).

Now help the user with: $ARGUMENTS
