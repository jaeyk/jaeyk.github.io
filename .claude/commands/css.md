Add or modify styles for this Quarto website by editing `styles.scss`. Never edit `styles.css` directly — it is the compiled output.

## Context

The site uses Bootstrap (via Quarto's `cosmo` theme) extended with custom SCSS in `styles.scss`. There are also supplementary files in `css/`. The SCSS compiles to `styles.css` during `quarto render`.

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
$font-family-base: $font-serif;
```

### 4. Existing CSS Utility Classes

**`.carolina-blue` — highlight badge:**
```scss
.carolina-blue {
  color: #4B9CD3 !important;
  background-color: #e8edf7;
  padding: 1px 5px;
  border-radius: 4px;
  font-weight: 600;
}
```

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
// Sidebar
#quarto-sidebar { }
.sidebar-navigation { }
.sidebar-item { }

// Table of contents
#TOC { }
.toc-title { }

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
| Body text | Source Serif 4 | 400 |
| Headings (H1–H3) | Source Serif 4 | 600 |
| Sidebar links | Inter | 400/500 |
| Code blocks | Monospace (system) | 400 |

### 10. Color Quick Reference

| Name | Hex | Use |
|---|---|---|
| Carolina Blue | `#4B9CD3` | Links, accents, primary |
| Dark Blue | `#13294B` | Headers, dark backgrounds |
| Badge BG | `#e8edf7` | `.carolina-blue` background |
| Gray | `#E0E0E0` | Borders, dividers |
| White | `#FFFFFF` | Backgrounds |

### 11. After Editing

Run `quarto render` to compile SCSS and rebuild the site. Check with `quarto preview` first.

Now help the user with: $ARGUMENTS
