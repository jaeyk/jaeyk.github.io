if(!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse, ggthemes, glue)

# Load file
df <- read.csv("coauthors_jae_yeon_kim.csv") %>%
  as_tibble() %>%
  mutate(departmenet = trimws(department))

# Correct a typo
df$institution[str_detect(df$institution, "Phew")] <- "Pew Research Center"

# Visualize
df %>%
  mutate(fields = if_else(str_detect(tolower(department), "political|social|snf|government|inequ|socio|policy"), 
         "Political Science/Public Policy/Sociology/Computational Social Science", "Others")) %>%
  mutate(fields = fct_relevel(fields, "Others", after = 2)) %>%
  group_by(institution, fields) %>%
  summarize(n = n()) %>%
  ungroup() %>%
  ggplot(aes(x = fct_reorder(institution, n), y = n, fill = fields)) +
    geom_col() +
    coord_flip() +
    ggthemes::theme_fivethirtyeight() +
    labs(x = "", y = "Count", 
         title = "Coauthors' Affiliated Institutions",
         subtitle = "Including the coauthors of published and working papers",
         caption = glue("Update: {Sys.Date()}"),
         fill = "Field") +
    theme(legend.position = "bottom")

ggsave("coauthors.png", width = 10, height= 10)