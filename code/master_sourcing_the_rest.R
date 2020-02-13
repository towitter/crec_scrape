# SPOSM - master
# simone euler, tobias witter


lib <- c("tidyverse", "rvest", "tidyr", "stringr", "tm", "plyr", "dplyr", 
         "lubridate", "data.table", "readr", "wordcloud", "tidytext", 
         "textdata") 
lapply(lib, require, character.only = T) 


## STEP 2: enter dates you want to download the records for -----------------

start_date <- ymd("2012-07-01")
end_date <- ymd("2013-06-30")


## STEP 3: download the records as html-files and save them in "output" -----

system.time(source("code/1_scraper.R"))
save_warnings <- warnings()


## STEP 4: parse html-files and tidy them in the dataframe "my_data" --------

system.time(source("code/2_clean_html_files.R"))

index_of_scraped_text <- my_data %>%
  select(vol, no, date, unit, start_page, end_page) %>%
  mutate(year = year(date))

# introduce NAs for dates where no congressional record is available
dta <- expand.grid(seq(start_date, end_date, 1), c("Daily Digest", "Extensions of Remarks", "House", "Senate"))
names(dta) <- c("date", "unit")
my_data <- merge(dta, my_data, by = c("date", "unit"), all.x = T)


## STEP 5: data visualization -----------------------------------------------

source("code/3_data_visualisation.R")

# function count words
my_data <- my_data %>% mutate(
  nchar = nchar(text),
  page_length = abs(end_page - start_page))

my_data <- my_data %>%
  mutate(nchar = ifelse(is.na(nchar), 0, nchar),
         page_length = ifelse(is.na(page_length), 0, page_length))

# ANALYSIS OF THE EXTENT OF CONGRESSIONAL RECORDS
# visualize the variation of number of characters over time by unit
my_data %>% 
  mutate(nchar = ifelse(is.na(text), 0, nchar(text))) %>%
  ggplot(aes(date, nchar, group=unit, color=unit)) +
  geom_line() +
  scale_color_manual(values = trr_palette, name = "Congress unit")+
  theme_classic()

# visualize the share of number of characters per month by each unit
my_data %>% 
  # aggregate dates to monthly values
  mutate(date = floor_date(date, "month")) %>%
  mutate(nchar = ifelse(is.na(text), 0, nchar(text))) %>%
  ggplot(aes(date, nchar)) +
  geom_bar(aes(color = unit, fill = unit),
           stat = "identity", position = position_stack())+
  scale_color_manual(values = trr_palette, name = "Congress unit")+
  scale_fill_manual(values = trr_palette, name = "Congress unit")+
  theme_classic()

# ANALYSIS OF WORDS IN CONGRESSIONAL RECORDS
# transform "my_data" to "words" by tokenizing words
words <- as_tibble(my_data) %>% 
  unnest_tokens(output = "word",
                token = "words", 
                input = text) %>%
  dplyr::count(date, unit, word, sort = TRUE)


# visualize top 10 most frequent words per unit
#senate
get_top_10_words(startdate = "2012-07-01", enddate =  "2012-12-30", congressunit = "Senate")

# house
get_top_10_words("2013-01-28", "2013-01-31", "House")

# daily digest
get_top_10_words("2012-07-01", "2013-01-31", "Daily Digest")

# extension of remarks
get_top_10_words("2012-07-01", "2013-01-31", "Extensions of Remarks")

# visualize top 10 most frequent words for all units
# not happy with results: words are not orderd by n
words %>%
  group_by(unit, word) %>% 
  dplyr::summarise(n = sum(n))%>% 
  arrange(desc(n))%>% 
  slice(1:10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = unit)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = trr_palette)+
  facet_wrap(~unit, scales = "free_y") +
  labs(y = "Frequency",
       x = NULL) +
  coord_flip()

# visualize a wordcloud per unit
get_wordcloud(startdate = "2012-07-01", 
              enddate =  "2013-06-30", 
              congressunit = "House")

# visualize the usage of certain keywords per unit over time
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

# SENTIMENT ANALYSIS
# visualize the usage of negative and postive words over time for all units
words %>%
  # aggregate dates to monthly values
  #mutate(date = floor_date(words$date, "month")) %>%
  # join words with sentiments dictionary
  inner_join(get_sentiments("bing"))%>%
  dplyr::count(unit, date, sentiment)%>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)%>%
  #plotting
  ggplot(aes(date, sentiment, fill = unit))+
  geom_col(show.legend = FALSE)+
  scale_fill_manual(values = trr_palette)+
  facet_wrap(~unit, ncol = 2, scales = "free_x")

# frequency of sadness words in congressional records
words %>%
  # aggregate dates to monthly values
  mutate(date = floor_date(date, "month")) %>%
  # join words with sentiments dictionary
  inner_join(get_sentiments("nrc")) %>%
  # filter only a specific sentiment
  filter(sentiment %in% c("sadness", "joy", "fear", "anger", "trust")) %>%
  dplyr::count(date, word, sentiment, sort =TRUE) %>%
  group_by(date, sentiment) %>% 
  dplyr::summarise(n = sum(n))%>%
  ggplot(aes(date, n, color = sentiment))+
  #scale_color_manual(values = trr_palette, name = "Sentiments")+
  theme_classic()+
  geom_line()# function count e.g. states



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




### END OF CODE ###