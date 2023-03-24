if(!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse, ggthemes, glue, patchwork, ggpmisc)

# Load file
df <- read.csv("coauthors_jae_yeon_kim.csv") %>%
  as_tibble() %>%
  mutate(departmenet = trimws(department))

# Visualize
affil_plot <- df %>%
  #mutate(fields = if_else(str_detect(tolower(department), "political|social|snf|government|inequ|socio|policy|interna|org|busi|mana"), 
   #      "Social sciences", "Others (e.g., Engineering)")) %>%
  #mutate(fields = fct_relevel(fields, "Others (e.g., Engineering)", after = 2)) %>%
  group_by(institution, year) %>%
  summarize(n = n()) %>%
  ungroup() %>%
  ggplot(aes(x = fct_reorder(institution, n), y = n, fill = year)) +
    geom_col() +
    coord_flip() +
    labs(x = "", y = "Count", 
         title = "Coauthors' Affiliated Institutions",
         subtitle = glue("Including the coauthors of published, \n working papers, and research proposals"),
         caption = glue("Update: {Sys.Date()}"),
         fill = "Year") +
    theme(legend.position = "bottom")

year_plot <- df %>%
  group_by(year) %>%
  count() %>%
  ggplot(aes(x = year, y = n)) +
  geom_point() +
  stat_poly_line() +
  stat_poly_eq(aes(label = paste(after_stat(eq.label)))) +
  labs(x = "Year", y = "# of the new coauthors")

affil_plot + year_plot + plot_annotation(tag_levels = "A")

ggsave("coauthors.png", width = 14, height= 10)