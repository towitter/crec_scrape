##SPOSM
# simone euler, tobias witter

## STEP 1: working enviornment setup --------------------------
lib <- c("tidytext", "dplyr", "ggplot2", "readr", "wordcloud") 
lapply(lib, require, character.only = T) 

# TRR266 colors
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

# transform dataframe to words
words <- as_tibble(my_data) %>%
  unnest_tokens(output = "word",
                token = "words", 
                input = text) %>%
  dplyr::count(date, unit, word, sort = TRUE)


## STEP 2: analysis ------------------------------------------
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


# apply function
get_top_10_words(startdate = "2012-07-01", enddate =  "2012-12-30", congressunit = "Senate")
get_top_10_words("2013-01-28", "2013-01-31", "House")
get_top_10_words("2012-07-01", "2013-01-31", "Daily Digest")
get_top_10_words("2012-07-01", "2013-01-31", "Extensions of Remarks")

# FUNCTION: CREATE WORDCLOUD 
get_wordcloud <- function(startdate, enddate, congressunit){
  #data arrangement
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

#apply function
get_wordcloud(startdate = "2012-08-29", enddate =  "2013-04-30", congressunit = "Senate")
get_wordcloud(startdate = "2013-01-28", enddate =  "2013-01-29", congressunit = "House")

# FUNCTION: KEYWORD SEARCH OVER TIME
keyword_over_time <- function(startdate, enddate, congressunit, keywords){
  over_time <- words %>%
    filter(date >= startdate & date <= enddate , unit == congressunit,  word %in% c(keywords)) %>%
    group_by(date, unit, word) %>% 
    dplyr::summarise(n = sum(n)) %>% 
    arrange(desc(date))
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

#apply function
keyword_over_time(startdate = "2012-07-01", 
                  enddate = "2013-06-30",
                  congressunit = "Senate",
                  keywords = c("defense", "foreign", "immigration"))

