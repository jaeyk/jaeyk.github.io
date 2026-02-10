#| label: partners-map
#| message: false
#| warning: false
#| fig-cap: "Geographic distribution of partners (city-level)."
#| fig-width: 9
#| fig-height: 6

if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("maps", quietly = TRUE)) install.packages("maps")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("ggrepel", quietly = TRUE)) install.packages("ggrepel")
if (!requireNamespace("stringr", quietly = TRUE)) install.packages("stringr")

library(ggplot2)
library(maps)
library(dplyr)
library(ggrepel)
library(stringr)
library(here)
library(plotly)
library(htmlwidgets)

partners <- tibble::tribble(
  ~org, ~category, ~city, ~state, ~lat, ~lon,
  "Office of Evaluation Sciences", "Federal government", "Washington", "DC", 38.9072, -77.0369,
  "California Department of Social Services", "State & local government", "Sacramento", "CA", 38.5816, -121.4944,
  "City of San Jose, Communications Office", "State & local government", "San Jose", "CA", 37.3382, -121.8863,
  "Colorado Department of Health Care Policy and Financing", "State & local government", "Denver", "CO", 39.7392, -104.9903,
  "Boulder County Housing and Human Services", "State & local government", "Boulder", "CO", 40.0150, -105.2705,
  "Government AI Coalition (San José)", "State & local government", "San Jose", "CA", 37.3382, -121.8863,
  "Massachusetts Department of Early Education and Care", "State & local government", "Boston", "MA", 42.3601, -71.0589,
  "New Mexico Human Services Department", "State & local government", "Santa Fe", "NM", 35.6870, -105.9378,
  "New York State Department of Health", "State & local government", "Albany", "NY", 42.6526, -73.7562,
  "Code for America", "Civic tech", "San Francisco", "CA", 37.7749, -122.4194,
  "Asian Americans Advancing Justice–Atlanta", "Advocacy & voter mobilization", "Atlanta", "GA", 33.7490, -84.3880,
  "Asian American Advocacy Fund", "Advocacy & voter mobilization", "Atlanta", "GA", 33.7490, -84.3880,
  "Students Learn Students Vote Coalition", "Advocacy & voter mobilization", "Washington", "DC", 38.9072, -77.0369,
  "Hispanics in Philanthropy", "Philanthropy", "Oakland", "CA", 37.8044, -122.2712
)

us_map <- map_data("state")

# Wrap labels at ~25 characters and add hover text
partners <- partners %>%
  mutate(
    label = str_wrap(org, width = 25),
    hover_text = paste0(org, "\n", city, ", ", state, "\nCategory: ", category),
    # Set category order for legend
    category = factor(category, levels = c(
      "Federal government",
      "State & local government",
      "Civic tech",
      "Philanthropy",
      "Advocacy & voter mobilization"
    ))
  )

p <- ggplot() +
  geom_polygon(
    data = us_map,
    aes(long, lat, group = group),
    fill = "grey95", color = "grey70", linewidth = 0.3
  ) +
  coord_quickmap(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  geom_point(
    data = partners,
    aes(x = lon, y = lat, shape = category),
    size = 3, alpha = 0.9
  ) +
  geom_label_repel(
    data = partners,
    aes(x = lon, y = lat, label = label),
    fill = "grey20", color = "white",
    size = 3, label.size = 0.2, label.padding = grid::unit(0.15, "lines"),
    max.overlaps = 20, seed = 123,
    show.legend = FALSE
  ) +
  scale_shape_discrete(name = "Category") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.text = element_text(size = 10),
    legend.title = element_text(face = "bold"),
    legend.key.size = unit(0.6, "cm"),
    legend.spacing.x = unit(0.5, "cm"),
    legend.spacing.y = unit(0.2, "cm"),
    legend.box.just = "center",
    legend.justification = "center",
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank()
  ) +
  guides(shape = guide_legend(nrow = 2, byrow = TRUE))

# Build a plotly-compatible version without geom_label_repel.
p_interactive <- ggplot() +
  geom_polygon(
    data = us_map,
    aes(long, lat, group = group),
    fill = "grey95", color = "grey70", linewidth = 0.3
  ) +
  coord_quickmap(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  geom_point(
    data = partners,
    aes(x = lon, y = lat, shape = category),
    size = 3, alpha = 0.9
  ) +
  scale_shape_discrete(name = "Category") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.text = element_text(size = 10),
    legend.title = element_text(face = "bold"),
    legend.key.size = unit(0.6, "cm"),
    legend.spacing.x = unit(0.5, "cm"),
    legend.spacing.y = unit(0.2, "cm"),
    legend.box.just = "center",
    legend.justification = "center",
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank()
  ) +
  guides(shape = guide_legend(nrow = 2, byrow = TRUE))

# Convert to interactive plotly map
interactive_map <- ggplotly(p_interactive) %>%
  layout(
    title = NULL,
    hoverlabel = list(bgcolor = "white", font = list(size = 12)),
    margin = list(l = 0, r = 0, t = 50, b = 20),
    legend = list(
      orientation = "h",
      x = 0.5,
      xanchor = "center",
      y = -0.1,
      yanchor = "top"
    ),
    # Add annotations for organization names
    annotations = lapply(seq_len(nrow(partners)), function(i) {
      list(
        x = partners$lon[i],
        y = partners$lat[i],
        text = partners$label[i],
        showarrow = FALSE,
        font = list(size = 9, color = "white"),
        bgcolor = "rgba(50, 50, 50, 0.8)",
        borderpad = 2,
        xanchor = "center",
        yanchor = "bottom",
        yshift = 10
      )
    })
  ) %>%
  # Configure plotly display options
  config(displayModeBar = TRUE, displaylogo = FALSE)
interactive_map$x$layout$title <- NULL

# Add hover text to marker traces by category and hide default hover for map polygon.
category_levels <- levels(partners$category)
category_text <- lapply(category_levels, function(cat) {
  partners %>%
    filter(as.character(category) == cat) %>%
    pull(hover_text)
})

for (i in seq_along(interactive_map$x$data)) {
  tr <- interactive_map$x$data[[i]]
  trace_name <- if (is.null(tr$name)) "" else as.character(tr$name)
  cat_index <- match(trace_name, category_levels)
  is_fill_trace <- identical(tr$hoveron, "fills") || identical(tr$mode, "lines")

  if (!is.na(cat_index)) {
    interactive_map$x$data[[i]]$text <- category_text[[cat_index]]
    interactive_map$x$data[[i]]$hovertemplate <- "%{text}<extra></extra>"
    interactive_map$x$data[[i]]$hoverinfo <- "text"
  } else if (is_fill_trace) {
    interactive_map$x$data[[i]]$hoverinfo <- "skip"
    interactive_map$x$data[[i]]$hovertemplate <- NULL
  } else {
    interactive_map$x$data[[i]]$hovertemplate <- "%{x}, %{y}<extra></extra>"
  }
}

# Save as HTML widget
saveWidget(
  interactive_map,
  file = here("misc", "partner_map.html"),
  selfcontained = TRUE
)

# Also keep PNG version for backward compatibility
png(here("misc", "partner_map.png"), width = 9, height = 6, units = "in", res = 300)
print(p) # plot object created above
dev.off()
