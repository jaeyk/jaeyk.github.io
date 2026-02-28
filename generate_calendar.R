# generate_calendar.R
#
# Quarto pre-render script: reads Talk, Panel, Discussant, and Participant
# badge events from index.qmd and writes talks/calendar-events.js.
#
# Workflow:
#   1. Edit badge rows in index.qmd (add/update/remove events)
#   2. Run: quarto render
#   3. This script regenerates talks/calendar-events.js automatically

lines <- readLines("index.qmd", encoding = "UTF-8")

# ── Month name lookup (full + abbreviated) ───────────────────────────────────
month_map <- c(
  January=1, February=2, March=3, April=4, May=5, June=6,
  July=7, August=8, September=9, October=10, November=11, December=12,
  Jan=1, Feb=2, Mar=3, Apr=4, Jun=6, Jul=7, Aug=8,
  Sep=9, Oct=10, Nov=11, Dec=12
)

parse_event_date <- function(date_str, year) {
  # Remove range end: "June 27–28" -> "June 27", "Nov 12-16" -> "Nov 12"
  date_str <- trimws(sub(paste0("[", "\u2013", "\u2014", "\\-]\\s*\\d+\\s*$"), "", date_str, perl = TRUE))
  parts <- strsplit(trimws(date_str), "\\s+")[[1]]
  if (length(parts) < 2) return(NA_character_)
  month_num <- month_map[parts[1]]
  day       <- suppressWarnings(as.integer(gsub("[^0-9]", "", parts[2])))
  if (is.na(month_num) || is.na(day)) return(NA_character_)
  format(as.Date(sprintf("%d-%02d-%02d", year, month_num, day)), "%Y-%m-%d")
}

# Badge types to include and their future colors (Material 700-series — readable with white text)
badge_colors <- c(
  "badge-talk"        = "#388e3c",
  "badge-panel"       = "#1976d2",
  "badge-discussant"  = "#00796b",
  "badge-participant" = "#6d4c41"
)

# ── Parse table rows ──────────────────────────────────────────────────────────
events       <- list()
current_year <- NULL

for (line in lines) {
  # Detect year from section headers ("2025 News", "2026 News", etc.)
  if (grepl("202[4-9].*News", line)) {
    m <- regmatches(line, regexpr("202[4-9]", line))
    if (length(m) > 0) current_year <- as.integer(m)
  }

  if (is.null(current_year))       next
  if (!grepl("^\\s*\\|", line))    next   # must be a table row

  # Detect which badge type this row has (if any), matching by name
  event_type <- NA_character_
  for (badge in names(badge_colors)) {
    if (grepl(badge, line, fixed = TRUE)) { event_type <- badge; break }
  }
  if (is.na(event_type)) next

  parts <- strsplit(line, "\\|")[[1]]
  parts <- trimws(parts[nchar(trimws(parts)) > 0])
  if (length(parts) < 4) next

  date_raw  <- parts[1]
  event_raw <- parts[3]
  place_raw <- trimws(gsub("\\*[^*]*\\*", "", parts[4]))  # strip *italics*

  # Extract first URL from event text (perl=TRUE so \s matches whitespace in class)
  url_m <- regmatches(event_raw, regexpr("https?://[^)\\s\"'>]+", event_raw, perl = TRUE))
  url   <- if (length(url_m) > 0) url_m else NA_character_

  # Clean title: [text](url) -> text, strip {.class}, (*...*), *italics*, extra spaces
  title <- event_raw
  title <- gsub("\\[([^\\]]+)\\]\\([^)]+\\)", "\\1", title, perl = TRUE)
  title <- gsub("\\{[^}]+\\}", "", title, perl = TRUE)
  title <- gsub("\\(\\*[^)]*\\*\\)", "", title, perl = TRUE)
  title <- gsub("\\*([^*]+)\\*", "\\1", title, perl = TRUE)
  title <- trimws(gsub("\\s{2,}", " ", title, perl = TRUE))

  # Split: extract "hosted by ..." then org from first comma
  host <- NA_character_
  if (grepl(",\\s*hosted by ", title, perl = TRUE)) {
    host  <- trimws(sub("^.*,\\s*hosted by ", "", title, perl = TRUE))
    title <- trimws(sub(",\\s*hosted by .+$", "", title, perl = TRUE))
  }
  org <- NA_character_
  m_comma <- regexpr(",\\s*", title, perl = TRUE)
  if (m_comma > 0) {
    org   <- trimws(substr(title, m_comma + attr(m_comma, "match.length"), nchar(title)))
    title <- trimws(substr(title, 1, m_comma - 1))
    if (nchar(org) == 0) org <- NA_character_
  }

  start <- parse_event_date(date_raw, current_year)
  if (is.na(start)) next

  events[[length(events) + 1]] <- list(
    start      = start,
    title      = title,
    org        = org,
    host       = host,
    place      = place_raw,
    url        = url,
    event_type = event_type
  )
}

# ── Build JS event objects ────────────────────────────────────────────────────
today <- format(Sys.Date(), "%Y-%m-%d")

safe_js <- function(s) {
  s <- gsub("\\\\", "\\\\\\\\", s)
  s <- gsub('"', '\\\\"', s)
  s
}

js_objects <- vapply(events, function(e) {
  is_past      <- e$start < today
  future_color <- badge_colors[e$event_type]
  color        <- if (is_past) "#aaaaaa" else future_color
  url_ln       <- if (!is.na(e$url)) sprintf('      url: "%s",\n', safe_js(e$url)) else ""
  org_val      <- if (!is.na(e$org))  safe_js(e$org)  else ""
  host_val     <- if (!is.na(e$host)) safe_js(e$host) else ""

  sprintf(
    '    {\n      title: "%s",\n      start: "%s",\n      color: "%s",\n%s      extendedProps: { org: "%s", host: "%s", place: "%s", type: "%s", past: %s }\n    }',
    safe_js(e$title), e$start, color, url_ln,
    org_val, host_val, safe_js(e$place), safe_js(e$event_type), tolower(is_past)
  )
}, character(1))

# ── Write output ──────────────────────────────────────────────────────────────
js_out <- sprintf(
'// Auto-generated from index.qmd by generate_calendar.R
// Do not edit this file directly — update badge events in index.qmd,
// then run: quarto render
//
// Event type colors (future):  Talk #388e3c | Panel #1976d2 | Discussant #00796b | Participant #6d4c41
// Past events: #aaaaaa at 55%% opacity

document.addEventListener(\'DOMContentLoaded\', function () {
  var calendarEl = document.getElementById(\'calendar\');
  if (!calendarEl) return;

  var events = [
%s
  ];

  var calendar = new FullCalendar.Calendar(calendarEl, {
    initialView: window.innerWidth < 768 ? \'listMonth\' : \'dayGridMonth\',
    height: \'auto\',
    headerToolbar: {
      left: \'prev,next\',
      center: \'title\',
      right: \'\'
    },
    windowResize: function (view) {
      calendar.changeView(window.innerWidth < 768 ? \'listMonth\' : \'dayGridMonth\');
    },
    events: events,
    eventContent: function (arg) {
      var props  = arg.event.extendedProps;
      var isPast = props.past;
      var wrapper = document.createElement(\'div\');
      wrapper.style.cssText = \'padding:2px 3px; white-space:normal; overflow:visible; line-height:1.4;\';
      var titleEl = document.createElement(\'div\');
      titleEl.style.cssText = \'font-weight:700; font-size:0.8em; color:#ffffff;\';
      titleEl.textContent = arg.event.title;
      wrapper.appendChild(titleEl);
      if (props.org) {
        var orgEl = document.createElement(\'div\');
        orgEl.style.cssText = \'font-size:0.76em; font-weight:700; color:#ffffff; margin-top:2px; text-decoration:underline; text-underline-offset:2px;\';
        orgEl.textContent = props.org;
        wrapper.appendChild(orgEl);
      }
      if (props.host) {
        var hostEl = document.createElement(\'div\');
        hostEl.style.cssText = \'font-size:0.73em; font-weight:700; color:#ffffff; margin-top:1px; font-style:italic;\';
        hostEl.textContent = \'by \' + props.host;
        wrapper.appendChild(hostEl);
      }
      if (props.place) {
        var placeEl = document.createElement(\'div\');
        var placeColor = isPast ? \'#bbbbbb\' : \'#ffffff\';
        placeEl.style.cssText = \'display:inline-block; font-size:0.72em; font-weight:600; color:\' + placeColor + \'; background:rgba(0,0,0,0.22); border-radius:3px; padding:1px 4px; margin-top:3px;\';
        placeEl.textContent = props.place;
        wrapper.appendChild(placeEl);
      }
      return { domNodes: [wrapper] };
    },
    eventDidMount: function (info) {
      if (info.event.extendedProps.past) {
        info.el.style.opacity = \'0.55\';
      }
    },
    eventClick: function (info) {
      info.jsEvent.preventDefault();
      if (info.event.url) {
        window.open(info.event.url, \'_blank\');
      } else {
        var props = info.event.extendedProps;
        var msg = info.event.title;
        if (props.place) msg += \'\\n\' + props.place;
        alert(msg);
      }
    }
  });

  calendar.render();
});
',
  paste(js_objects, collapse = ",\n")
)

writeLines(js_out, "talks/calendar-events.js")
message(sprintf("[generate_calendar.R] Wrote %d talk events to talks/calendar-events.js",
                length(events)))
