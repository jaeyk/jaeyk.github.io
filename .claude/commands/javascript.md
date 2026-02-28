Add or modify JavaScript on this Quarto website, following its established patterns for DOM manipulation, external libraries, and Quarto integration.

## Context

This site uses JavaScript in three ways:
1. **Global custom JS** — injected via `_quarto.yml`'s `include-in-header`
2. **Page-level inline JS** — written directly inside `.qmd` files in `<script>` tags
3. **Standalone `.js` files** — referenced by specific pages (e.g., `talks/calendar-events.js`)

## Instructions

### 1. Always Wrap DOM Code

All code that touches the DOM must use DOMContentLoaded:
```javascript
document.addEventListener('DOMContentLoaded', function() {
  // your code here
});
```

### 2. Where to Put JavaScript

| Use case | Location |
|---|---|
| Site-wide behavior | `_quarto.yml` → `format.html.include-in-header` |
| Single-page behavior | `<script>` block inside the `.qmd` file |
| Complex page feature | Separate `.js` file in the page's directory |

**Adding to `_quarto.yml` (global):**
```yaml
format:
  html:
    include-in-header:
      - text: |
          <script>
          document.addEventListener('DOMContentLoaded', function() {
            // code
          });
          </script>
```

**Adding inline to a `.qmd` page:**
```html
<script>
document.addEventListener('DOMContentLoaded', function() {
  // code
});
</script>
```

**Adding a standalone file (e.g., for a feature-rich page):**
```yaml
# In the .qmd frontmatter:
format:
  html:
    include-in-header:
      - text: '<script src="calendar-events.js"></script>'
```

### 3. Loading External Libraries via CDN

Add in frontmatter's `include-in-header`, before any code that uses the library:
```yaml
format:
  html:
    include-in-header:
      - text: |
          <script src="https://cdn.jsdelivr.net/npm/js-yaml@4.1.0/dist/js-yaml.min.js"></script>
```

**Libraries already available site-wide (loaded by Quarto/Bootstrap):**
- Bootstrap JS (modals, tooltips, etc.)
- Quarto's navigation and search scripts
- Clipboard.js

### 4. Existing Site Patterns to Follow or Extend

**Search placeholder customization:**
```javascript
document.addEventListener('DOMContentLoaded', function() {
  var searchInput = document.querySelector('#quarto-search input[type="text"]');
  if (searchInput) {
    searchInput.setAttribute('placeholder', 'Search this site...');
  }
});
```

**Reversed list counter (auto-sizes from item count):**
```javascript
document.querySelectorAll('.reversed-list > ol').forEach(function(ol) {
  var wrapper = ol.closest('.reversed-list');
  var itemCount = Array.from(ol.children).filter(function(child) {
    return child.tagName === 'LI';
  }).length;
  wrapper.style.setProperty('--reversed-counter-reset', String(itemCount + 1));
});
```

**YAML-driven publication search (from `publications/pubs.qmd`):**
```javascript
fetch('data/published-papers.yml')
  .then(response => response.text())
  .then(text => {
    const papers = jsyaml.load(text);
    // filter and render papers
  });
```

**FullCalendar integration (from `talks/calendar-events.js`):**
```javascript
document.addEventListener('DOMContentLoaded', function () {
  var calendarEl = document.getElementById('calendar');
  var calendar = new FullCalendar.Calendar(calendarEl, {
    initialView: 'dayGridMonth',
    events: [ /* event objects */ ],
    eventClick: function(info) {
      if (info.event.url) {
        window.open(info.event.url, '_blank');
        info.jsEvent.preventDefault();
      }
    }
  });
  calendar.render();
});
```

### 5. Quarto-Specific DOM Selectors

| Selector | What it targets |
|---|---|
| `#quarto-search input[type="text"]` | Sidebar search input |
| `.quarto-title` | Page title element |
| `#quarto-sidebar` | Left sidebar container |
| `.sidebar-navigation` | Sidebar nav links |
| `.reversed-list > ol` | Reversed-numbered lists |

### 6. What NOT to Do

- Do not use jQuery — vanilla JS only (or a CDN-loaded library)
- Do not use `document.write()`
- Do not modify Quarto's generated navigation scripts
- Do not block rendering — keep scripts non-blocking (DOMContentLoaded or `defer`)
- Do not duplicate the Google Analytics script (already in `_quarto.yml`)

Now help the user with: $ARGUMENTS
