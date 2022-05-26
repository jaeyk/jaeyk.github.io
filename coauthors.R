if(!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse, ggthemes)

df <- read.csv("coauthors_jae_yeon_kim.csv") %>%
  as_tibble()

df %>%
  mutate(fields = if_else(str_detect(tolower(department), "political|social|snf|government|inequ|socio|policy"), 
         "Political Science/Public Policy/Sociology/Computational Social Science", "Others")) %>%
  group_by(institution, fields) %>%
  summarize(n = n()) %>%
  ungroup() %>%
  ggplot(aes(x = fct_reorder(institution, n), y = n, fill = fields)) +
    geom_col() +
    coord_flip() +
    theme_clean() +
    labs(x = "", y = "Count", 
         title = "Coauthors' Affiliated Institutions",
         subtitle = "Including the coauthors of published and working papers",
         fill = "Field") +
    theme(legend.position = "bottom")

ggsave("coauthors.png")