# generate_calendar.R
#
# Quarto pre-render script: reads Talk, Panel, Discussant, and Participant
# badge events from index.qmd and writes calendar data for the homepage and talks page.
#
# Workflow:
#   1. Edit badge rows in index.qmd (add/update/remove events)
#   2. Run: quarto render
#   3. This script regenerates talks/calendar-events.js and talks/upcoming-talks.js

lines <- readLines("index.qmd", encoding = "UTF-8")

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || is.na(x)) y else x
}

# ── Month name lookup (full + abbreviated) ───────────────────────────────────
month_map <- c(
  January=1, February=2, March=3, April=4, May=5, June=6,
  July=7, August=8, September=9, October=10, November=11, December=12,
  Jan=1, Feb=2, Mar=3, Apr=4, Jun=6, Jul=7, Aug=8,
  Sep=9, Oct=10, Nov=11, Dec=12
)

build_date <- function(year, month_token, day_token) {
  month_num <- unname(month_map[month_token])
  day <- suppressWarnings(as.integer(gsub("[^0-9]", "", day_token)))
  if (length(month_num) == 0 || is.na(month_num) || is.na(day)) return(NA_character_)
  format(as.Date(sprintf("%d-%02d-%02d", year, as.integer(month_num), day)), "%Y-%m-%d")
}

parse_event_dates <- function(date_str, year) {
  date_str <- trimws(gsub("\\s+", " ", date_str, perl = TRUE))
  if (!nzchar(date_str)) return(NULL)

  range_parts <- strsplit(date_str, paste0("\\s*[", "\u2013", "\u2014", "\\-]\\s*"), perl = TRUE)[[1]]
  range_parts <- trimws(range_parts)
  if (length(range_parts) == 0) return(NULL)

  start_tokens <- strsplit(range_parts[1], "\\s+")[[1]]
  if (length(start_tokens) < 2) return(NULL)
  start <- build_date(year, start_tokens[1], start_tokens[2])
  if (is.na(start)) return(NULL)

  end_inclusive <- start
  if (length(range_parts) > 1 && nzchar(range_parts[2])) {
    end_tokens <- strsplit(range_parts[2], "\\s+")[[1]]
    if (length(end_tokens) >= 2) {
      end_candidate <- build_date(year, end_tokens[1], end_tokens[2])
    } else {
      end_candidate <- build_date(year, start_tokens[1], end_tokens[1])
    }
    if (!is.na(end_candidate)) {
      end_inclusive <- end_candidate
    }
  }

  start_date <- as.Date(start)
  end_date <- as.Date(end_inclusive)
  if (end_date < start_date) return(NULL)

  list(
    start = format(start_date, "%Y-%m-%d"),
    end = if (end_date > start_date) format(end_date + 1, "%Y-%m-%d") else NA_character_,
    end_inclusive = format(end_date, "%Y-%m-%d")
  )
}

# Badge types to include and their future colors (Material 700-series — readable with white text)
badge_colors <- c(
  "badge-talk"        = "#388e3c",
  "badge-panel"       = "#1976d2",
  "badge-discussant"  = "#00796b",
  "badge-participant" = "#6d4c41"
)

strip_markdown <- function(s) {
  s <- gsub("\\[([^\\]]+)\\]\\([^)]+\\)", "\\1", s, perl = TRUE)
  s <- gsub("\\{[^}]+\\}", "", s, perl = TRUE)
  s <- gsub("\\(\\*[^)]*\\*\\)", "", s, perl = TRUE)
  s <- gsub("\\*([^*]+)\\*", "\\1", s, perl = TRUE)
  trimws(gsub("\\s{2,}", " ", s, perl = TRUE))
}

# ── Parse table rows ──────────────────────────────────────────────────────────
events       <- list()
current_year <- NULL

for (line in lines) {
  # Backward-compatible fallback for older year-section tables.
  if (grepl("202[4-9].*News", line)) {
    m <- regmatches(line, regexpr("202[4-9]", line))
    if (length(m) > 0) current_year <- as.integer(m)
  }

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

  row_year <- suppressWarnings(as.integer(parts[1]))
  if (!is.na(row_year) && length(parts) >= 5) {
    year      <- row_year
    date_raw  <- parts[2]
    event_raw <- parts[4]
    place_raw <- trimws(gsub("\\*[^*]*\\*", "", parts[5]))
  } else {
    if (is.null(current_year)) next
    year      <- current_year
    date_raw  <- parts[1]
    event_raw <- parts[3]
    place_raw <- trimws(gsub("\\*[^*]*\\*", "", parts[4]))
  }
  if (grepl("^-+$", date_raw)) next

  # Extract first URL from event text (perl=TRUE so \s matches whitespace in class)
  url_m <- regmatches(event_raw, regexpr("https?://[^)\\s\"'>]+", event_raw, perl = TRUE))
  url   <- if (length(url_m) > 0) url_m else NA_character_

  # Clean title: [text](url) -> text, strip {.class}, (*...*), *italics*, extra spaces
  title <- strip_markdown(event_raw)

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

  date_info <- parse_event_dates(date_raw, year)
  if (is.null(date_info)) next

  events[[length(events) + 1]] <- list(
    start      = date_info$start,
    end        = date_info$end,
    end_inclusive = date_info$end_inclusive,
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

safe_html <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;", s, fixed = TRUE)
  s <- gsub(">", "&gt;", s, fixed = TRUE)
  s <- gsub('"', "&quot;", s, fixed = TRUE)
  s
}

js_objects <- vapply(events, function(e) {
  comparison_end <- if (!is.na(e$end)) e$end else format(as.Date(e$start) + 1, "%Y-%m-%d")
  is_past      <- comparison_end <= today
  future_color <- badge_colors[e$event_type]
  color        <- if (is_past) "#aaaaaa" else future_color
  url_ln       <- if (!is.na(e$url)) sprintf('      url: "%s",\n', safe_js(e$url)) else ""
  end_ln       <- if (!is.na(e$end)) sprintf('      end: "%s",\n', e$end) else ""
  org_val      <- if (!is.na(e$org))  safe_js(e$org)  else ""
  host_val     <- if (!is.na(e$host)) safe_js(e$host) else ""

  sprintf(
    '    {\n      title: "%s",\n      start: "%s",\n%s      color: "%s",\n%s      extendedProps: { org: "%s", host: "%s", place: "%s", type: "%s", past: %s }\n    }',
    safe_js(e$title), e$start, end_ln, color, url_ln,
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
  var mobileQuery = window.matchMedia(\'(max-width: 768px)\');
  function preferredView() {
    return mobileQuery.matches ? \'listMonth\' : \'dayGridMonth\';
  }

  var events = [
%s
  ];

  function todayKeyLocal() {
    var now = new Date();
    var y = now.getFullYear();
    var m = String(now.getMonth() + 1).padStart(2, \'0\');
    var d = String(now.getDate()).padStart(2, \'0\');
    return y + \'-\' + m + \'-\' + d;
  }

  function eventStartKey(startValue) {
    if (typeof startValue === \'string\') {
      return startValue.slice(0, 10);
    }
    var dt = new Date(startValue);
    if (isNaN(dt.getTime())) return null;
    var y = dt.getFullYear();
    var m = String(dt.getMonth() + 1).padStart(2, \'0\');
    var d = String(dt.getDate()).padStart(2, \'0\');
    return y + \'-\' + m + \'-\' + d;
  }

  function eventEndKey(event) {
    if (event.end) {
      var endKey = eventStartKey(event.end);
      if (!endKey) return null;
      var dt = new Date(endKey + \'T00:00:00\');
      if (isNaN(dt.getTime())) return endKey;
      dt.setDate(dt.getDate() - 1);
      var y = dt.getFullYear();
      var m = String(dt.getMonth() + 1).padStart(2, \'0\');
      var d = String(dt.getDate()).padStart(2, \'0\');
      return y + \'-\' + m + \'-\' + d;
    }
    return eventStartKey(event.start);
  }

  // Recompute past/future styling in the browser so builds do not go stale.
  var todayKey = todayKeyLocal();
  events.forEach(function (event) {
    var endKey = eventEndKey(event);
    var isPast = !!endKey && endKey < todayKey;
    if (!event.extendedProps) event.extendedProps = {};
    event.extendedProps.past = isPast;
    event.color = isPast ? \'#aaaaaa\' : event.color;
  });

  var calendar = new FullCalendar.Calendar(calendarEl, {
    initialView: preferredView(),
    height: \'auto\',
    headerToolbar: {
      left: \'prev,next\',
      center: \'title\',
      right: \'\'
    },
    events: events,
    displayEventTime: false,
    eventContent: function (arg) {
      var props  = arg.event.extendedProps;
      var isPast = props.past;
      var isListView = arg.view.type.indexOf(\'list\') === 0;
      var wrapper = document.createElement(\'div\');
      wrapper.style.cssText = isListView
        ? \'padding:2px 0; white-space:normal; overflow:visible; line-height:1.4;\'
        : \'padding:2px 3px; white-space:normal; overflow:visible; line-height:1.4;\';
      var titleEl = document.createElement(\'div\');
      titleEl.style.cssText = isListView
        ? \'font-weight:700; font-size:0.92em; color:#1f2937;\'
        : \'font-weight:700; font-size:0.8em; color:#ffffff;\';
      titleEl.textContent = arg.event.title;
      wrapper.appendChild(titleEl);
      if (props.org) {
        var orgEl = document.createElement(\'div\');
        orgEl.style.cssText = isListView
          ? \'font-size:0.79em; font-weight:700; color:#0f172a; margin-top:2px; text-decoration:underline; text-underline-offset:2px;\'
          : \'font-size:0.76em; font-weight:700; color:#ffffff; margin-top:2px; text-decoration:underline; text-underline-offset:2px;\';
        orgEl.textContent = props.org;
        wrapper.appendChild(orgEl);
      }
      if (props.host) {
        var hostEl = document.createElement(\'div\');
        hostEl.style.cssText = isListView
          ? \'font-size:0.77em; font-weight:600; color:#4b5563; margin-top:1px; font-style:italic;\'
          : \'font-size:0.73em; font-weight:700; color:#ffffff; margin-top:1px; font-style:italic;\';
        hostEl.textContent = \'by \' + props.host;
        wrapper.appendChild(hostEl);
      }
      if (props.place) {
        var placeEl = document.createElement(\'div\');
        var placeColor = isListView ? \'#334155\' : (isPast ? \'#bbbbbb\' : \'#ffffff\');
        var placeBg = isListView ? \'rgba(148,163,184,0.18)\' : \'rgba(0,0,0,0.22)\';
        placeEl.style.cssText = \'display:inline-block; font-size:0.72em; font-weight:600; color:\' + placeColor + \'; background:\' + placeBg + \'; border-radius:3px; padding:1px 4px; margin-top:3px;\';
        placeEl.textContent = props.place;
        wrapper.appendChild(placeEl);
      }
      return { domNodes: [wrapper] };
    },
    eventDidMount: function (info) {
      if (info.event.extendedProps.past) {
        info.el.style.opacity = info.view.type.indexOf(\'list\') === 0 ? \'0.75\' : \'0.55\';
      }
    },
    windowResize: function () {
      var viewName = preferredView();
      if (calendar.view.type !== viewName) {
        calendar.changeView(viewName);
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

format_display_date <- function(start, end_inclusive) {
  start_date <- as.Date(start)
  end_date <- as.Date(end_inclusive)
  month_label <- function(d) {
    month_names <- c("Jan.", "Feb.", "March", "April", "May", "June",
                     "July", "Aug.", "Sept.", "Oct.", "Nov.", "Dec.")
    sprintf("%s %d", month_names[as.integer(format(d, "%m"))], as.integer(format(d, "%d")))
  }
  start_label <- month_label(start_date)
  if (is.na(end_date) || end_date <= start_date) return(start_label)
  if (format(start_date, "%Y-%m") == format(end_date, "%Y-%m")) {
    return(sprintf("%s-%d", start_label, as.integer(format(end_date, "%d"))))
  }
  end_label <- month_label(end_date)
  sprintf("%s-%s", start_label, end_label)
}

event_end_for_sort <- function(e) {
  if (!is.na(e$end_inclusive)) as.Date(e$end_inclusive) else as.Date(e$start)
}

today_date <- Sys.Date()
future_events <- events[vapply(events, function(e) event_end_for_sort(e) >= today_date, logical(1))]
if (length(future_events) > 0) {
  future_events <- future_events[order(vapply(future_events, function(e) as.Date(e$start), as.Date("1970-01-01")))]
}
homepage_events <- head(future_events, 5)

landing_items <- vapply(homepage_events, function(e) {
  date_label <- safe_html(format_display_date(e$start, e$end_inclusive))
  detail <- if (!is.na(e$org) && nzchar(e$org)) {
    sprintf("%s, %s", e$title, e$org)
  } else {
    e$title
  }
  detail <- safe_html(detail)
  if (!is.na(e$url) && nzchar(e$url)) {
    detail <- sprintf('<a href="%s">%s</a>', safe_html(e$url), detail)
  }
  sprintf('      <li><time datetime="%s">%s.</time> %s</li>', e$start, date_label, detail)
}, character(1))

upcoming_out <- sprintf(
'// Auto-generated from index.qmd by generate_calendar.R
// Do not edit this file directly.

document.addEventListener("DOMContentLoaded", function () {
  var list = document.getElementById("landing-talk-list");
  if (!list) return;
  list.innerHTML = `%s`;
});
',
  paste(landing_items, collapse = "\n")
)

writeLines(upcoming_out, "talks/upcoming-talks.js")

papers <- yaml::read_yaml("publications/data/published-papers.yml")
paper_order <- vapply(papers, function(p) {
  if (!is.null(p$order)) as.numeric(p$order) else as.numeric(p$year %||% 0)
}, numeric(1))
papers <- papers[order(paper_order, decreasing = TRUE)]
recent_papers <- head(papers, 3)

publication_items <- vapply(recent_papers, function(p) {
  title <- safe_html(p$title %||% "")
  venue <- safe_html(p$venue %||% "")
  citation <- safe_html(p$citation %||% "")
  meta <- trimws(paste(c(venue, citation)[nzchar(c(venue, citation))], collapse = ", "))
  title_markup <- if (!is.null(p$url) && nzchar(p$url)) {
    sprintf('<a href="%s">%s</a>', safe_html(p$url), title)
  } else {
    title
  }
  sprintf("      <li>%s%s</li>",
          title_markup,
          if (nzchar(meta)) sprintf(" <span>%s</span>", meta) else "")
}, character(1))

recent_publications_out <- sprintf(
'// Auto-generated from publications/data/published-papers.yml by generate_calendar.R
// Do not edit this file directly.

document.addEventListener("DOMContentLoaded", function () {
  var list = document.getElementById("landing-publication-list");
  if (!list) return;
  list.innerHTML = `%s`;
});
',
  paste(publication_items, collapse = "\n")
)

writeLines(recent_publications_out, "publications/recent-publications.js")
message(sprintf("[generate_calendar.R] Wrote %d talk events, %d upcoming events, and %d recent publications",
                length(events), length(homepage_events), length(recent_papers)))
