# Load necessary libraries
library(ggplot2)
library(dplyr)
library(forcats)
library(stringr)

# --- Data Preparation ---
# Your career data
# We'll use a data frame to store the roles, years, and categories.
# The `end_year` for ongoing roles is set to the current year plus one for visualization.
career_data <- tibble::tribble(
  ~role, ~category, ~start_year, ~end_year, ~sort_order,
  "Assistant Professor of Public Policy, UNC–Chapel Hill", "Academic", 2026, 2027, 10,
  "Better Government Lab Fellow, Michigan Ford School", "Academic", 2024, 2027, 20,
  "Research Fellow, Harvard Kennedy School", "Academic", 2024, 2026, 30,
  "Senior Data Scientist, Contracting Data Scientist, Code for America", "Civic Tech", 2023, 2026, 40,
  "Co-Founder, Data for Good Roundtables", "Leadership", 2025, 2027, 50,
  "Advisory Board Member, Summer Institute in Computational Social Science", "Leadership", 2023, 2027, 60,
  "Member, Procurement Committee, GovAI Coalition", "Leadership", 2025, 2027, 70,
  "Pre/Postdoc Fellow, Research Fellow, Assistant Research Scientist, Johns Hopkins", "Academic", 2020, 2025, 80,
  "Assistant Professor of Data Science, KDI School of Public Policy and Management (South Korea)", "Academic", 2022, 2023, 90,
  "Ph.D., Political Science, UC Berkeley", "Academic", 2020, 2021, 100
)

# Sort the data by category (in the specified order) and then by start year
career_data <- career_data %>%
  mutate(category = factor(category, levels = c("Academic", "Civic Tech", "Leadership"))) %>%
  arrange(category, sort_order) %>%
  mutate(role = str_wrap(role, width = 35)) %>%
  mutate(role = fct_inorder(role)) %>%
  mutate(role = fct_rev(role))

# --- Create the Gantt Chart using ggplot2 ---
p <- ggplot(career_data, aes(x = start_year, xend = end_year, y = role, color = category)) +
  # Add segments to represent each role's duration
  geom_segment(size = 8, aes(x = start_year, xend = end_year, y = role, yend = role)) +
  # Use labels for each role
  labs(
    title = "My Non-Linear Career Path",
    subtitle = "A visual timeline of academic, civic tech, and leadership/advisory roles",
    x = "Year",
    y = "",
    color = "Role Category"
  ) +
  # Customize the theme to remove gridlines and improve aesthetics
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.text.y = element_text(size = 10, face = "bold"),
    plot.title = element_text(size = 16, face = "bold"),
    legend.position = "bottom"
  ) +
  # Set the color palette for the categories
  scale_color_manual(values = c("Academic" = "#3b82f6", "Civic Tech" = "#10b981", "Leadership" = "#f59e0b")) +
  # Set the x-axis breaks to be whole years
  scale_x_continuous(breaks = min(career_data$start_year):max(career_data$end_year))

# --- Save the plot to a file ---
# Use ggsave to save the plot as a high-resolution PNG
# The plot will be saved to your working directory

png("career_gantt_chart.png", width = 12, height = 8, units = "in", res = 300)
print(p)
dev.off()
