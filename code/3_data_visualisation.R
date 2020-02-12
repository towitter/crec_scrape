##SPOSM
# simone euler, tobias witter

## STEP 1: working enviornment setup --------------------------
#lib <- c("tidyverse","readr", "tidytext", "wordcloud") 
#lapply(lib, require, character.only = T) 

# TRR266 colors 
# credit: https://github.com/joachim-gassen/sposm
lighten <- function(color, factor = 0.5) {
  if ((factor > 1) | (factor < 0)) stop("factor needs to be within [0,1]")
  col <- col2rgb(color)
  col <- col + (255 - col)*factor
  col <- rgb(t(col), maxColorValue=255)
  col
}

trr266_petrol <- rgb(27, 138, 143, 255, maxColorValue = 255)
trr266_lightpetrol <- lighten(trr266_petrol, 0.5)
trr266_blue <- rgb(110, 202, 226, 255, maxColorValue = 255)
trr266_yellow <- rgb(255, 180, 59, 255, maxColorValue = 255)
trr266_red <- rgb(148, 70, 100, 255, maxColorValue = 255)

trr_palette <- c(trr266_red, trr266_blue, trr266_yellow, trr266_petrol, trr266_lightpetrol)

# NOTICE: all the following function can only be applied when the dataframe is transfered
# into a tibble called "words" that is tokenized by "word" 
# (see Step 5 of "master_sourcing_the_rest.R" for further details)

# FUNCTION: GET TOP 10 WORDS
get_top_10_words <- function(startdate, enddate, congressunit){
  # amount of words for caption label
  number <- words %>% 
    filter(date >= startdate & date <= enddate, unit == congressunit)%>%
    group_by(unit) %>% 
    summarize(all = sum(n))
  # create plot
  return(
    words %>% 
      filter(date >= startdate & date <= enddate , unit == congressunit)%>%
      group_by(unit, word) %>% 
      dplyr::summarise(n = sum(n)) %>% 
      arrange(desc(n))%>% 
      slice(1:10) %>%
      mutate(word = reorder(word, n)) %>%
      ggplot(aes(word, n)) +
      geom_col()+
      coord_flip()+
      labs(title = as.character(congressunit),
           subtitle = paste0("Top 10 Most Frequent Words from ", startdate," to ", enddate),
           caption = paste0(number$all," words counted in total"),
           x = " ", 
           y = "Frequency") +
      theme_classic()+
      theme(plot.title = element_text(size = 14, face = "bold", color = trr266_petrol, vjust = -1),
            plot.subtitle = element_text(size = 10, color = trr266_lightpetrol),
            plot.caption = element_text(size = 10, hjust = 0.5, face = "italic", color = trr266_lightpetrol),
            plot.margin = margin(1, 1, 1, 1, "cm"),) +
      geom_bar(stat="identity", fill = trr266_lightpetrol) +
      geom_text(aes(label = n), hjust = 1.2, colour = trr266_petrol, fontface = "bold")
  )
}

# FUNCTION: CREATE WORDCLOUD 
get_wordcloud <- function(startdate, enddate, congressunit){
  # data arrangement
  cloud <- words %>%
    filter(date >= startdate & date <= enddate , unit == congressunit)%>%
    group_by(word) %>%
    dplyr::summarise(n = sum(n)) %>%
    arrange(desc(n))
  # create wordcloud
  set.seed(1234)
  return(wordcloud(words = cloud$word, 
                   freq = cloud$n,
                   max.words = 100, 
                   random.order=FALSE, rot.per=0.35, 
                   colors=trr_palette))
}

# FUNCTION: KEYWORD SEARCH OVER TIME
keyword_over_time <- function(startdate, enddate, congressunit, keywords){
  # data arrangement
  over_time <- words %>%
    filter(date >= startdate & date <= enddate , unit == congressunit,  word %in% c(keywords)) %>%
    group_by(date, unit, word) %>% 
    dplyr::summarise(n = sum(n)) %>% 
    arrange(desc(date))
  # create plot
  return(
    ggplot(over_time, aes(x = date, y = n, color = word)) + 
      geom_line() +
      scale_color_manual(values = trr_palette, name = "Keywords")+
      theme_classic()+
      labs(title = as.character(congressunit),
           subtitle = "Development of Keywords Over Time",
           x = "Date", 
           y = "Frequency")+
      theme(plot.title = element_text(size = 14, face = "bold", color = trr266_petrol, vjust = -1),
            plot.subtitle = element_text(size = 10, color = trr266_lightpetrol),
            plot.margin = margin(1, 1, 1, 1, "cm"))
  )
}