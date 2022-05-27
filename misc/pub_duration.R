if(!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse, clipr, ggthemes)

vec <- str_split("14
          330
          949
          186
          59
          230
          317
          236
          171
          24
          169", " ")

vec <- vec %>% unlist() %>% readr::parse_number()

df <- data.frame(duration = vec[!is.na(vec)]) %>%
  rowid_to_column("id")

df %>%
  ggplot(aes(x = duration)) +
  geom_histogram() +
  labs(title = "The # of days from the first submission to the final acceptance.",
       subtitle = "The two journals might not be the same ones.",
       x = "", 
       y = "Duration") +
  theme_wsj() +
  geom_vline(xintercept = 365, col = "red", linetype = "dotted", size = 2)