# SPOSM - master
# simone euler, tobias witter

## STEP 1: working enviornment setup ----------------------------------------
# packages required for using the scripts
lib <- c("RCurl", "tidyverse", "rvest", "plyr", "tm")

# install required packages, if not installed and load all packages
lapply(lib, function(x){if(x %in% rownames(installed.packages()) == FALSE) {install.packages(x)}})
lapply(lib, require, character.only = T)  


## STEP 2: enter dates you want to download the records for -----------------

start_date <- as.Date("2012-12-28", origin="1970-01-01")
end_date <- as.Date("2013-01-05", origin="1970-01-01")
date_sequence <- seq(start_date, end_date, 1)


# base url for zipped files
base_url <- "https://www.govinfo.gov/content/pkg/CREC-"
end_url <- paste0(date_sequence, ".zip")

# zip file url for scraping
zip_url <- paste0(base_url, end_url)

# function to check existence of a URL
# (not every day has a Congress session)
does_url_exist <- data.frame("date" = as.character(date_sequence, origin="1970-01-01"),
                             "exists" = url.exists(zip_url))

## STEP 3: download the records as html-files and save them in "output" -----

# script scrapes zip files from govinfo.com, then extracts 
# html files of Congress debates
system.time(source("code/1_scraper.R"))

# save warnings from parsing the data
# warnings tell you for which date no Congress debate data was 
# available from govinfo.com
save_warnings <- warnings()


## STEP 4: parse html-files and tidy them in the dataframe "my_data" --------

# this script parses and cleans the html data
# it extracts the data in 
system.time(source("code/2_parse_and_clean_html_files.R"))

index_of_scraped_text <- data_frame_with_texts %>%
  select(vol, no, date, unit, start_page, end_page) %>%
  mutate(year = format(date, "%Y"))

# introduce NAs for dates where no congressional record is available
dta <- expand.grid(seq(start_date, end_date, 1), c("Daily Digest", "Extensions of Remarks", "House", "Senate"))
names(dta) <- c("date", "unit")
data_frame_with_texts <- merge(dta, data_frame_with_texts, by = c("date", "unit"), all.x = T)

### END OF CODE ###