###############################################################################
#  Co-Author Dashboard: Bar Chart + Robinson Bubble Map (robust geocoding)
#  -----------------------------------------------------------------------
#  * Parses community_building/coauthors.md
#  * Draws a bar chart (RA vs non-RA)
#  * Geocodes institutions with:
#       1) manual override table  (inst_override.csv)
#       2) cached OSM look-ups    (inst_geocode_cache.csv)
#       3) sanity check to flag obvious misfires (e.g., Latin-America hits)
#  * Builds a Robinson-projected bubble map
###############################################################################

## ── 0 · Packages ────────────────────────────────────────────────────────────
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(
  tidyverse, here, fs, glue,
  showtext, ggsci,
  tidygeocoder, sf,
  rnaturalearth, rnaturalearthdata
)

showtext_auto()
font_add_google("Inter", "inter")

out_dir <- here("community_building")
fs::dir_create(out_dir)

## ── 1 · Read + parse coauthors.md ───────────────────────────────────────────
md_lines <- readLines(here("community_building", "coauthors.md"), encoding = "UTF-8")

list_items <- md_lines |>
  str_subset("^\\d+\\.\\s") |>
  str_remove("\\s*\\*$")        # drop trailing “*”

collaborators <- tibble(
  ra          = str_detect(list_items, "\\*$"),
  name        = str_match(list_items, "^\\d+\\.\\s*(.*?)\\s*\\(")[, 2],
  institution = str_match(list_items, "\\(([^)]+)\\)")[, 2]
) |>
  drop_na(name, institution)

## ── 2 · Bar chart ───────────────────────────────────────────────────────────
inst_counts <- collaborators |>
  count(institution, ra, name = "n") |>
  mutate(
    ra_label    = ifelse(ra, "Undergrad RA", "Co-author"),   # readable legend
    institution = fct_reorder(institution, n, .fun = sum)    # order by total
  )

bar_plot <- ggplot(inst_counts,
                   aes(institution, n, fill = ra_label, label = n)) +
  
  # stacked bars coloured by RA status
  geom_col(width = 0.8) +
  
  # put count labels inside each segment
  geom_text(position = position_stack(vjust = 0.5),
            colour   = "white", size = 4) +
  
  scale_fill_manual(
    values = c("Co-author"   = "#2c7fb8",
               "Undergrad RA" = "#a1dab4"),
    name   = NULL
  ) +
  
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, .1))) +
  
  labs(
    title    = "Where My Co-Authors Work",
    subtitle = glue("Last updated: {format(Sys.Date(), '%Y-%m')}  •  N = {nrow(collaborators)}"),
    x = NULL, y = "Number of collaborators"
  ) +
  
  theme_minimal(base_family = "inter", base_size = 14) +
  theme(
    axis.title.y    = element_text(size = 16),
    axis.text.y     = element_text(size = 14),
    plot.title.position = "plot",
    legend.position = "bottom",
    plot.margin     = margin(5.5, 30, 5.5, 5.5)
  )

ggsave(here(out_dir, "coauthors.png"),
       plot = bar_plot, width = 7, height = 4.5, dpi = 300, bg = "white")

## ── 3 · Geocode institutions (override → cache → OSM) ───────────────────────
geo_cache    <- here("community_building", "inst_geocode_cache.csv")
override_csv <- here("community_building", "inst_override.csv")

override_tbl <- if (file.exists(override_csv)) {
  read_csv(override_csv, show_col_types = FALSE)
} else {
  tibble(institution = character(), latitude = numeric(), longitude = numeric())
}

cache_tbl <- if (file.exists(geo_cache)) {
  read_csv(geo_cache, show_col_types = FALSE)
} else {
  tibble(institution = character(), latitude = numeric(), longitude = numeric())
}

# Institutions still needing lookup
lookup_targets <- inst_counts |>
  distinct(institution) |>
  anti_join(override_tbl, by = "institution") |>
  anti_join(cache_tbl,    by = "institution")

if (nrow(lookup_targets) > 0) {
  message("⏳  Geocoding ", nrow(lookup_targets), " new institution(s)…")
  new_coords <- lookup_targets |>
    geocode(institution, method = "osm",
            lat = latitude, long = longitude, quiet = TRUE)
  cache_tbl  <- bind_rows(cache_tbl, new_coords)
  write_csv(cache_tbl, geo_cache)
}

geo_data <- bind_rows(override_tbl, cache_tbl)

inst_geo <- inst_counts |>
  left_join(geo_data |> select(institution, latitude, longitude),
            by = "institution") |>
  drop_na(latitude, longitude) |>
  group_by(institution) |>
  summarise(
    n         = sum(.data$n),          # ← use .data to disambiguate
    latitude  = first(latitude),
    longitude = first(longitude),
    .groups   = "drop"
  )

## Sanity check: flag anything landing in Latin America
latin_hit <- inst_geo |>
  filter(latitude < 10, latitude > -60,
         longitude > -120, longitude < -30)

if (nrow(latin_hit) > 0) {
  warning(
    "⚠️  These institutions geocoded to Latin America.\n",
    "    Add correct lat/long to inst_override.csv and rerun:\n",
    paste0("   • ", latin_hit$institution, collapse = "\n")
  )
}

## ── 4 · Robinson bubble map (cropped, legend bottom, larger fonts) ──────────
world_robin <- ne_countries(scale = "medium", returnclass = "sf") |>
  st_transform("ESRI:54030")

inst_sf <- st_as_sf(inst_geo,
                    coords = c("longitude", "latitude"),
                    crs = 4326) |>
  st_transform("ESRI:54030")

map_plot <- ggplot() +
  geom_sf(data = world_robin, fill = "#f0f0f0",
          colour = "grey70", linewidth = 0.2) +
  geom_sf(data = inst_sf, aes(size = n),
          colour = pal_aaas("default")(8)[1], alpha = 0.7) +
  scale_size_area(max_size = 10, name = "Co-authors") +
  coord_sf(ylim = c(-6000000, 8500000)) +           # crop Arctic fringe
  labs(
    title    = "Global Footprint of My Co-Authors",
    subtitle = glue("Last updated: {format(Sys.Date(), '%Y-%m')}"),
    x = NULL, y = NULL
  ) +
  theme_minimal(base_family = "inter", base_size = 15) +
  theme(
    panel.grid.major = element_blank(),
    legend.position  = "bottom"
  )

ggsave(here(out_dir, "coauthors_map.png"),
       plot = map_plot, width = 9, height = 5.5, dpi = 300, bg = "white")
