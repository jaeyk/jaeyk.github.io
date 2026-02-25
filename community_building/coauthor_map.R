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

# Coordinates are institutional centroids used for map visualization.
affiliation_coordinates <- tribble(
  ~affiliation, ~latitude, ~longitude,
  "Aarhus University", 56.1710, 10.2039,
  "Ben-Gurion University", 31.2614, 34.7996,
  "Cambridge", 52.2053, 0.1218,
  "Code for America", 37.7749, -122.4194,
  "Columbia", 40.8075, -73.9626,
  "Dartmouth", 43.7044, -72.2887,
  "Fordham Law", 40.7712, -73.9647,
  "Georgetown", 38.9076, -77.0723,
  "Harvard", 42.3770, -71.1167,
  "Hebrew University of Jerusalem", 31.7719, 35.1970,
  "Johns Hopkins", 39.3299, -76.6205,
  "Loyola Marymount University", 33.9680, -118.4167,
  "MIT", 42.3601, -71.0942,
  "Meta", 37.4848, -122.1484,
  "Michigan", 42.2780, -83.7382,
  "Monash", -37.9105, 145.1364,
  "Monash University (Melbourne, Australia)", -37.9105, 145.1364,
  "Northwestern", 42.0565, -87.6753,
  "Oxford", 51.7548, -1.2544,
  "Pew Research", 38.9040, -77.0375,
  "Rochester", 43.1566, -77.6088,
  "SUNY Albany", 42.6860, -73.8238,
  "SUNY Binghamton", 42.0887, -75.9690,
  "Santa Clara University", 37.3496, -121.9390,
  "Syracuse", 43.0481, -76.1474,
  "Tel Aviv University", 32.1133, 34.8044,
  "Tufts", 42.4075, -71.1190,
  "UC Berkeley", 37.8719, -122.2585,
  "UC Davis", 38.5382, -121.7617,
  "UCLA", 34.0689, -118.4452,
  "UIUC", 40.1020, -88.2272,
  "UPenn", 39.9522, -75.1932,
  "US Government Accountability Office", 38.8895, -77.0091,
  "University of Connecticut", 41.8084, -72.2495,
  "University of Southern California", 34.0224, -118.2851,
  "Virginia", 38.0349, -78.5056,
  "Wesleyan", 41.5584, -72.6565,
  "Yonsei University", 37.5658, 126.9386
)

coauthors <- read_coauthors_table(here("community_building", "coauthors.qmd"))

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
