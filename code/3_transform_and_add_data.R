library(tidyverse)
library(readr)

# https://www.infoplease.com/us/government/legislative-branch/composition-of-congress-by-political-party-1855-2017
# for info on Congress composition over time

index_of_scraped_text <- my_data %>%
  select(vol, no, date, unit, start_page, end_page, pages) %>%
  mutate(year = year(date))

file <- "raw_data/congress_composition.txt"
congress_compo <- read_tsv(file, col_names = TRUE) %>%
  mutate(congress = gsub("[^0-9]", "", congress)) %>%
  separate(., years, into = c("year_from", "year_to"),
           sep = " ", remove = T, convert = T, extra = "warn", fill = "warn")

# function count e.g. states

# function count words
my_data <- my_data %>% mutate(
  nchar = nchar(text),
  page_length = abs(end_page - start_page))

# visualizations
idx <- c(1, diff(my_data$date))
i2 <- c(1, which(idx != 1), nrow(df)+1)
my_data$grp <- rep(1:length(diff(i2)), diff(i2))

my_data %>%
  ggplot(aes(date, page_length, group=unit, color=unit)) +
  geom_point()

# function count political topics or department or agency names

# sentiment analysis