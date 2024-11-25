
if (!require(pamcan)) install.packages("pacman")

pacman::p_load(tidyverse, glue, here)

# Step 1: Read the .md file
file_path <- here("community_building", "coauthors.md")
lines <- readLines(file_path, encoding = "UTF-8")

# Step 2: Extract the list items
# Assuming each list item starts with "- "
list_items <- lines[grepl("^\\d+\\.\\s", lines)]

# Step 3: Parse the items into a data frame
# Extract the names and institutions
collaborators <- tibble(
  Name = str_extract(list_items, "(?<=- ).+?(?= \\()"),    # Extract name before "("
  Institution = str_extract(list_items, "(?<=\\().+?(?=\\))") # Extract institution inside "()"
)

# Step 4: Count the number of collaborators per institution
institution_counts <- collaborators %>%
  count(Institution, sort = TRUE)

# Step 5: Plot the bar chart
last_updated <- format(Sys.Date(), "%Y-%m") # Format as "Year-Month"

png(here("community_building", "coauthors.png"))  # Specify width and height in pixels

ggplot(institution_counts, aes(x = reorder(Institution, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + # Flip coordinates for better readability
  theme_minimal() +
  labs(
    title = "Distribution of Collaborators by Institution",
    subtitle = paste("Last updated:", last_updated),
    x = "Institution",
    y = "Number")

print(plot)

dev.off()