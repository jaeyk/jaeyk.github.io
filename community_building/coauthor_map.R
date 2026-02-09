# Load libraries
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyverse)
library(ggrepel)
library(here) # Load the 'here' package
library(plotly)
library(htmlwidgets)

# Combine your location with your collaborators' list
all_affiliations <- c(
  "UNC Chapel Hill", "Oxford", "Cambridge", "UC Berkeley", "UPenn", "Fordham Law", "Tufts", "Dartmouth", "Yonsei University",
  "Harvard", "Michigan", "Hebrew University of Jerusalem", "UCLA", "Georgetown", "Aarhus University",
  "Johns Hopkins", "Code for America", "University of Connecticut", "Rochester",
  "US Government Accountability Office", "Ben-Gurion University", "SUNY Binghamton", "SUNY Albany", "Wesleyan",
  "Virginia", "Tel Aviv University", "MIT", "UIUC", "Northwestern", "Pew Research", "Columbia",
  "Meta", "UC Davis", "Santa Clara University", "Korea University",
  "UC Berkeley", "UC Berkeley", "Dartmouth", "Dartmouth", "Harvard", "Harvard", "Johns Hopkins", "Michigan",
  "Michigan", "Michigan", "Michigan", "Georgetown", "Georgetown", "Georgetown", "UCLA", "Syracuse", "Syracuse"
)

# Calculate the total number of collaborators
total_collaborators <- length(all_affiliations)

# Count the occurrences of each affiliation
collaborators_count <- data.frame(affiliation = all_affiliations) %>%
  group_by(affiliation) %>%
  summarise(n = n())

# Data frame with unique affiliations and coordinates
unique_collaborators_data <- data.frame(
  affiliation = c("UNC Chapel Hill", "Oxford", "UC Berkeley", "UPenn", "Fordham Law", "Tufts", "Dartmouth", "Yonsei University", "Harvard", "Michigan", "Hebrew University of Jerusalem", "UCLA", "Georgetown", "Aarhus University", "Johns Hopkins", "Code for America", "University of Connecticut", "Rochester", "US Government Accountability Office", "Ben-Gurion University", "SUNY Binghamton", "Wesleyan", "Virginia", "Tel Aviv University", "MIT", "UIUC", "Northwestern", "Pew Research", "Columbia", "Meta", "UC Davis", "Santa Clara University", "Korea University"),
  latitude = c(35.90, 51.76, 37.87, 39.95, 40.77, 42.41, 43.70, 37.57, 42.37, 42.28, 31.79, 34.07, 38.91, 56.17, 39.33, 37.78, 41.81, 43.13, 38.90, 31.26, 42.09, 41.56, 38.03, 32.11, 42.36, 40.10, 42.06, 38.904, 40.81, 37.49, 38.54, 37.35, 37.59),
  longitude = c(-79.04, -1.25, -122.26, -75.19, -73.98, -71.12, -72.29, 126.94, -71.12, -83.74, 35.24, -118.44, -77.07, 10.20, -76.62, -122.41, -72.25, -77.63, -77.02, 34.80, -75.97, -72.66, -78.51, 34.80, -71.09, -88.23, -87.68, -77.0375, -73.96, -122.15, -121.76, -121.94, 127.03)
)

# Join the count data with the location data
full_collaborators_data <- unique_collaborators_data %>%
  left_join(collaborators_count, by = "affiliation")

# Filter the data for labels to only include affiliations with at least 2 coauthors
filtered_labels_data <- full_collaborators_data %>%
  filter(n >= 2)

# Convert to sf object
collaborators_sf <- st_as_sf(full_collaborators_data, coords = c("longitude", "latitude"), crs = 4326)

# Get the world map data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Find the coordinates for your location
unc_chapel_hill <- collaborators_sf[collaborators_sf$affiliation == "UNC Chapel Hill", ]

# Add hover text for interactivity
full_collaborators_data <- full_collaborators_data %>%
  mutate(hover_text = paste0(affiliation, "\nCollaborators: ", n))

# Update sf object with hover text
collaborators_sf <- st_as_sf(full_collaborators_data, coords = c("longitude", "latitude"), crs = 4326)

# Create the plot object and assign it to a variable
coauthor_map <- ggplot(data = world) +
  geom_sf(fill = "lightgrey", color = "black") +
  geom_sf(data = collaborators_sf, aes(size = n, text = hover_text), shape = 21, fill = "red", show.legend = FALSE) +
  geom_sf(data = unc_chapel_hill, aes(size = n, text = "UNC Chapel Hill\n(My Location)"), shape = 8, color = "gold", show.legend = FALSE) +
  geom_segment(
    data = full_collaborators_data[full_collaborators_data$affiliation != "UNC Chapel Hill", ],
    aes(
      x = longitude, y = latitude,
      xend = unc_chapel_hill$geometry[[1]][1],
      yend = unc_chapel_hill$geometry[[1]][2]
    ),
    color = "blue", linewidth = 0.5
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
interactive_map <- ggplotly(coauthor_map, tooltip = "text") %>%
  layout(
    title = NULL,
    hoverlabel = list(bgcolor = "white", font = list(size = 12)),
    margin = list(l = 0, r = 0, t = 50, b = 0)
  )
interactive_map$x$layout$title <- NULL

# Remove default "trace n" labels in hover tooltips
for (i in seq_along(interactive_map$x$data)) {
  tr <- interactive_map$x$data[[i]]
  text_vals <- if (is.null(tr$text)) character(0) else as.character(tr$text)
  has_nonempty_text <- length(text_vals) > 0 && any(nzchar(text_vals))

  if (has_nonempty_text) {
    interactive_map$x$data[[i]]$hovertemplate <- "%{text}<extra></extra>"
    interactive_map$x$data[[i]]$hoverinfo <- "text"
  } else {
    interactive_map$x$data[[i]]$hoverinfo <- "skip"
    interactive_map$x$data[[i]]$hovertemplate <- NULL
  }
}

# Save as HTML widget
saveWidget(
  interactive_map,
  file = here("misc", "coauthor_map.html"),
  selfcontained = TRUE
)

# Also keep PNG version for backward compatibility
png(filename = here("misc", "coauthor_map.png"), width = 10, height = 6, units = "in", res = 300)
print(coauthor_map)
dev.off()
