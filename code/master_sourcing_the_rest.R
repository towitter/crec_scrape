# SPOSM - master
# simone euler, tobias witter

## STEP 1: working enviornment setup ----------------------------------------
lib <- c("tidyverse", "lubridate", "data.table") 
lapply(lib, require, character.only = T)


## STEP 2: enter dates you want to download the records for -----------------
start_date <- ymd("2012-07-01")
end_date <- ymd("2013-06-30")


## STEP 3: download the records as html-files and save them in "output" -----
system.time(
  source("code/1_scraper.R")
  )

save_warnings <- warnings()


## STEP 4: parse html-files and tidy them in the dataframe "my_data" --------
system.time(
  source("code/2_clean_html_files.R")
)

# 
index_of_scraped_text <- my_data %>%
  select(vol, no, date, unit, start_page, end_page, pages) %>%
  mutate(year = year(date))

# introduce NAs for dates where no congressional record is available
dta <- expand.grid(seq(start_date, end_date, 1), c("Daily Digest", "Extensions of Remarks", "House", "Senate"))
names(dta) <- c("date", "unit")

my_data <- merge(dta, my_data, by = c("date", "unit"), all.x = T)
