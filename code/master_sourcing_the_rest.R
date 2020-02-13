# SPOSM - master
# simone euler, tobias witter

lib <- c("tidyverse", "rvest", "tidyr", "stringr", "tm", "plyr", "dplyr", 
         "lubridate", "data.table", "readr", "wordcloud", "tidytext") 
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
  select(vol, no, date, unit, start_page, end_page) %>%
  mutate(year = year(date))

dta <- expand.grid(seq(start_date, end_date, 1), c("Daily Digest", "Extensions of Remarks", "House", "Senate"))
names(dta) <- c("date", "unit")

my_data <- merge(dta, my_data, by = c("date", "unit"), all.x = T)

# function count e.g. states

# function count words
my_data <- my_data %>% mutate(
  nchar = nchar(text),
  page_length = abs(end_page - start_page))

my_data <- my_data %>%
  mutate(nchar = ifelse(is.na(nchar), 0, nchar),
         page_length = ifelse(is.na(page_length), 0, page_length))

# visualizations
png("plots/plot1.png", width = 1200, height = 700)
my_data %>%
  ggplot(aes(date, nchar, group=unit, color=unit)) +
  geom_line() +
  ggtitle("Number of characters over time",
          subtitle = paste0("N = ", sum(!is.na(my_data$text)), " days with a debate in Congress")) +
  xlab("Number of characters") + ylab("date (daily data)")
dev.off()

png("plots/plot2.png", width = 1200, height = 700)
my_data %>%
  filter(unit %in% c("House", "Senate")) %>%
  ggplot(aes(date, page_length)) +
  geom_line() + #ylim(-20,500) +
  facet_grid(unit ~ .) +
  ggtitle("Number of pages over time",
          subtitle = paste0("N = ", sum(!is.na(my_data$text)), " out of ", length(my_data$text), " days with a debate in Congress")) +
  xlab("date (daily data)") + ylab("Number of characters")
dev.off()

# get vis functions
system.time(
  source("code/3_data_visualisation.R")
)

# apply function

#senate
get_top_10_words(startdate = "2012-07-01", enddate =  "2012-12-30", congressunit = "Senate")

# house
get_top_10_words("2013-01-28", "2013-01-31", "House")

# daily digest
get_top_10_words("2012-07-01", "2013-01-31", "Daily Digest")

# extension of remarks
get_top_10_words("2012-07-01", "2013-01-31", "Extensions of Remarks")

#apply function
get_wordcloud(startdate = "2012-08-29", enddate =  "2013-04-30", congressunit = "Senate")
get_wordcloud(startdate = "2013-01-28", enddate =  "2013-01-29", congressunit = "House")


#apply function
keyword_over_time(startdate = "2012-07-01", 
                  enddate = "2013-06-30",
                  congressunit = "Senate",
                  keywords = c("gun", "violence", "war"))

keyword_over_time(startdate = "2012-07-01", 
                  enddate = "2013-06-30",
                  congressunit = "Senate",
                  keywords = c("joy", "peace", "happy"))


png("plots/plot3.png", width = 1200, height = 700)
keyword_over_time(startdate = "2012-07-01", 
                  enddate = "2013-06-30",
                  congressunit = "House",
                  keywords = c("sequester", "cliff"))
dev.off()

png("plots/plot4.png", width = 1200, height = 700)
keyword_over_time(startdate = "2012-07-01", 
                  enddate = "2013-06-30",
                  congressunit = "Senate",
                  keywords = c("peace", "war"))
dev.off()



### END OF CODE ###