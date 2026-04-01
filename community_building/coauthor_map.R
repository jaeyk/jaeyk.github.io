# Load libraries
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyverse)
library(here)
library(plotly)
library(htmlwidgets)

read_coauthors_table <- function(path) {
  lines <- readLines(path, warn = FALSE)

  table_rows <- lines %>%
    str_subset("^\\|") %>%
    str_subset("^\\|[- ]+\\|", negate = TRUE)

  parsed <- tibble(raw = table_rows) %>%
    mutate(parts = str_split(raw, "\\|")) %>%
    mutate(parts = map(parts, ~ str_trim(.x))) %>%
    transmute(
      name = map_chr(parts, ~ .x[2] %||% ""),
      affiliation = map_chr(parts, ~ .x[3] %||% ""),
      note = map_chr(parts, ~ .x[4] %||% "")
    ) %>%
    filter(name != "", name != "Name") %>%
    mutate(across(c(name, affiliation, note), str_squish))

  parsed
}

read_coauthors_data <- function(csv_path, qmd_path) {
  if (file.exists(csv_path)) {
    df <- readr::read_csv(csv_path, show_col_types = FALSE)
    has_coords <- all(c("Latitude", "Longitude") %in% names(df))
    return(
      df %>%
        transmute(
          name = str_squish(Name %||% ""),
          affiliation = str_squish(Affiliation %||% ""),
          note = str_squish(Note %||% ""),
          latitude = if (has_coords) Latitude else NA_real_,
          longitude = if (has_coords) Longitude else NA_real_
        ) %>%
        filter(name != "", affiliation != "")
    )
  }

  read_coauthors_table(qmd_path) %>%
    mutate(latitude = NA_real_, longitude = NA_real_)
}

coauthors <- read_coauthors_data(
  csv_path = here("community_building", "coauthors.csv"),
  qmd_path = here("community_building", "coauthors.qmd")
)

# Derive per-affiliation coordinates from the CSV (first non-NA value per group)
affiliation_coordinates <- coauthors %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  group_by(affiliation) %>%
  slice(1) %>%
  ungroup() %>%
  select(affiliation, latitude, longitude)

collaborators_count <- coauthors %>%
  count(affiliation, name = "n")

full_collaborators_data <- collaborators_count %>%
  left_join(affiliation_coordinates, by = "affiliation")

missing_coords <- full_collaborators_data %>%
  filter(is.na(latitude) | is.na(longitude))

if (nrow(missing_coords) > 0) {
  warning(
    "Missing coordinates for affiliations: ",
    paste(missing_coords$affiliation, collapse = ", ")
  )
  full_collaborators_data <- full_collaborators_data %>%
    filter(!is.na(latitude), !is.na(longitude))
}

if (nrow(full_collaborators_data) == 0) {
  stop("No coauthor affiliations with valid coordinates were found.")
}

# Convert to sf object
collaborators_sf <- st_as_sf(full_collaborators_data, coords = c("longitude", "latitude"), crs = 4326)

# Get the world map data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Home node used as map origin
unc_chapel_hill <- tibble(
  affiliation = "UNC Chapel Hill",
  latitude = 35.9049,
  longitude = -79.0469,
  n = 1L
)
unc_sf <- st_as_sf(unc_chapel_hill, coords = c("longitude", "latitude"), crs = 4326)

# Create the plot object and assign it to a variable
coauthor_map <- ggplot(data = world) +
  geom_sf(fill = "lightgrey", color = "black") +
  geom_sf(data = collaborators_sf, aes(size = n), shape = 21, fill = "red", show.legend = FALSE) +
  geom_sf(data = unc_sf, shape = 8, color = "gold", size = 4, show.legend = FALSE) +
  geom_segment(
    data = full_collaborators_data,
    aes(
      x = longitude,
      y = latitude,
      xend = unc_chapel_hill$longitude,
      yend = unc_chapel_hill$latitude
    ),
    color = "blue",
    linewidth = 0.5
  ) +
  coord_sf(xlim = c(-150, 150), ylim = c(-60, 90)) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank()
  )

# Convert to interactive plotly map
interactive_map <- ggplotly(coauthor_map) %>%
  layout(
    title = NULL,
    hoverlabel = list(bgcolor = "white", font = list(size = 12)),
    margin = list(l = 0, r = 0, t = 50, b = 0)
  )
interactive_map$x$layout$title <- NULL

# Remove default "trace n" labels in hover tooltips
for (i in seq_along(interactive_map$x$data)) {
  interactive_map$x$data[[i]]$hoverinfo <- "skip"
  interactive_map$x$data[[i]]$hovertemplate <- NULL
}

# Save as HTML widget
saveWidget(
  interactive_map,
  file = here("misc", "coauthor_map.html"),
  selfcontained = FALSE
)

# Also keep PNG version for backward compatibility
png(filename = here("misc", "coauthor_map.png"), width = 10, height = 6, units = "in", res = 300)
print(coauthor_map)
dev.off()
