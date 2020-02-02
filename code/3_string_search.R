install.packages("readr") # you only need to do this one time on your system
library(readr)
library(tidyverse)
require("tm")
library(ggplot2)

mystring <- read_file("C:/Users/Nutzer/Google Drive/Congressional Records Examples/data/text_example_crec-2013-01-01/text_example_2013-01-01.txt")
mystring <- str_remove_all(mystring, pattern = "\r")
mystring <- str_remove_all(mystring, pattern = "\n")
mystring <- str_remove_all(mystring, pattern = "[[:punct:]]")
mystring <- str_remove_all(mystring, pattern = "[[:punct:]]")
mystring <- str_to_lower(mystring, locale = "en")

removeWords(str, stopwords) # needed?


str_count(mystring, pattern = "and")
str_count(mystring, pattern = " and ")
str_count(mystring, pattern = "uncertainty") # gross und kleinschreibung?
str_count(mystring, pattern = "tax")
str_count(mystring, pattern = "medicare")

# funciton count states

# function count words
my_data <- my_data %>% mutate(
  nchar = nchar(text),
  page_length = abs(end_page - start_page))

my_data %>%
  ggplot(aes(date, page_length, group=unit, color=unit)) +
  geom_point()

# function count political topics or department or agency names

# sentiment analysis