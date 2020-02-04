# SPOSM - master
# simone euler, tobias witter

lib <- c("tidyverse", "lubridate", "data.table") 

#lapply(lib, install.packages)
lapply(lib, require, character.only = T)

# dates we want to download the records for
start_date <- ymd("2012-07-01")
end_date <- ymd("2013-06-30")

system.time(
  source("code/1_scraper.R")
  )

save_warnings <- warnings()


system.time(
  source("code/2_clean_html_files.R")
)

index_of_scraped_text <- my_data %>%
  select(vol, no, date, unit, start_page, end_page, pages) %>%
  mutate(year = year(date))

dta <- expand.grid(seq(start_date, end_date, 1), c("Daily Digest", "Extensions of Remarks", "House", "Senate"))
names(dta) <- c("date", "unit")

my_data <- merge(dta, my_data, by = c("date", "unit"), all.x = T)
