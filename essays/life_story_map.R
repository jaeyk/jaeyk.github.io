# Load necessary libraries
library(sf)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata) # It's good practice to be explicit with packages
library(ggrepel)
library(here) # A useful package for managing file paths

# A sample of your data
places <- data.frame(
  place = c("Jeonju, South Korea", "Daejeon, South Korea", "Seoul, South Korea",
            "Kowloon Tong, Hong Kong", "Muzha District, Taipei, Taiwan",
            "Vancouver, BC", "San Francisco Bay Area, CA",
            "Ann Arbor, MI", "Cambridge, MA", "Research Triangle, NC"),
  lon = c(127.1, 127.3, 126.9, 114.2, 121.6, -123.1, -122.4, -83.7, -71.1, -78.8),
  lat = c(35.8, 36.3, 37.5, 22.3, 25.0, 49.2, 37.8, 42.3, 42.4, 35.8)
)

# Get world map data
world_map <- ne_countries(scale = "medium", returnclass = "sf")

# Convert your data frame to an sf object
places_sf <- st_as_sf(places, coords = c("lon", "lat"), crs = 4326)

# Create the zoomed-in plot without gridlines
p <- ggplot() +
  # Plot the world map
  geom_sf(data = world_map, fill = "gray90", color = "gray50") +
  # Plot the points for each place lived
  geom_sf(data = places_sf, size = 3, color = "dodgerblue", alpha = 0.8) +
  # Add labels to the points with ggrepel to prevent overlapping
  geom_text_repel(data = places, aes(x = lon, y = lat, label = place),
                  size = 3,
                  box.padding = 0.5,
                  point.padding = 0.5,
                  max.overlaps = Inf) +
  # Zoom in on the Pacific region to show both North America and Asia
  # Adjust these values as needed for the desired view
  coord_sf(xlim = c(-150, 150), ylim = c(10, 60), expand = FALSE) +
  labs(title = "My Path Across North America and Asia",
       subtitle = "Places I've Lived") +
  # Remove all background elements like gridlines and axes
  theme_void()

# Open the PNG device to save the plot
png(here("misc", "life_story_map.png"), width = 10, height = 6, units = "in", res = 300)

# Print the plot to the device
print(p)

# Close the device
dev.off()
