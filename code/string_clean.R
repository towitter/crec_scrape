##SPOSM
# simone euler, tobias witter

## STEP 1: working enviornment setup --------------------------
lib <- c("rvest", "tidyr", "stringr", "tm", "plyr", "dplyr", "lubridate") 
lapply(lib, require, character.only = T) 

## STEP 2: create dataframe -----------------------------------

# create vector that contains different directories of scraping output
directories <- paste0("output/", dir("output"),"/html")

# create dataframe for html files
mydata <- NULL

# function to provide body from html file in a dataframe with 6 columnes
get_text_from_html <- function(html){
  body <- read_html(html) %>%
    html_nodes("body") %>%
    html_text()
  sep <- as.data.frame(str_split(body, "\n", n = 6, simplify = TRUE))
}

# save all html files in mydata
for(i in seq_along(directories)){
  
  # get file names from working directory
  files <- list.files(directories[i], pattern = "*.htm")
  
  # apply get_text function and save output in mydata
  for(row in seq_along(files)){
    mydata_row <- get_text_from_html(files[row])
    mydata <- rbind(mydata, mydata_row)
  }
  rm(mydata_row)
}

# rename columnes
mydata <- rename(mydata, empty = V1, vol_no_date = V2, unit = V3, pages = V4, link = V5, text = V6)

# summarize mydata along congress unit and date
mydata_sum <- ddply(mydata, .(vol_no_date, unit), summarize,
                    pages = paste(unique(pages), collapse = "-"),
                    text = paste(text, collapse = " "))


## STEP 3: cleaning dataframe ------------------------------

## helperfunctions
# date: extract date in format YYYY-MM-DD
clean_date <- function(vol_no_date){
  # first save your current locale
  loc <- Sys.getlocale("LC_TIME")
  # set correct locale for the strings to be parsed
  Sys.setlocale("LC_TIME", "C") 
  # Exctract and save as dates
  dates <- str_extract(string = vol_no_date ,pattern = "(?<=\\().*(?=\\))") %>%
    as.Date(format = "%A, %B %d, %Y")
  # then set back to your old locale
  Sys.setlocale("LC_TIME", loc)
  # Credit: https://stackoverflow.com/questions/13726894/strptime-as-posixct-and-as-date-return-unexpected-na
  return(dates)
}

# volumne: extract volumne no
clean_vol <- function(vol_no_date){
  vol_no_date <- gsub("\\s*\\([^\\)]+\\)","",as.character(vol_no_date)) %>%
    str_split_fixed(",",2)
  volumne <- as.numeric(str_extract(vol_no_date[,1], "(\\d)+"))
  return(volumne)
}

# number: extract number no
clean_no <- function(vol_no_date){
  vol_no_date <- gsub("\\s*\\([^\\)]+\\)","",as.character(vol_no_date)) %>%
    str_split_fixed(",",2)
  number <- as.numeric(str_extract(vol_no_date[,2], "(\\d)+"))
  return(number)
}

# unit: remove [] from unit
clean_unit <- function(unit){
  # remove []
  unit <- str_remove_all(unit, pattern = "\\[|\\]")
  unit <- as.factor(unit)
}

# page number: remove "page", "pages", [] and combine them to (min-page)-(max-page)
clean_pages <- function(page){
  # remove "Pages"
  page <- str_remove_all(page, pattern = "Pages ")
  # remove "Page" 
  page <- str_remove_all(page, pattern = "Page ")
  # remove []
  page <- str_remove_all(page, pattern = "\\[|\\]")
  
  # create [min]-[max] pages
  # introduce helpvectors
  unique_letter <- NA
  min_num <- NA
  max_num <- NA
  #extracting
  letter <- str_extract_all(page, "[A-Z]{1}")
  number <- str_extract_all(page, "\\d+")
  # loop to get unique letter and save them in helpvector
  for (i in seq_along(letter)){
    unique_letter[i] <- letter[[i]][1]
  }
  # loop to get min-page and max-page save them in helpvector
  for (i in seq_along(number)){
    min_num[i] <- min(number[[i]])
    max_num[i] <- max(number[[i]])
  }
  # helperfunction to join letter, min, max
  join_pages <- function (letter,min,max){
    if(min==max){
      output <- paste0(letter,min)
    } 
    else {
      output <- paste0(letter,min, "-", letter, max)  
    }
    return(output)
  }
  # loop to get min-page and max-page with the helperfunction join_pages
  for(i in seq_along(unique_letter)){
    page[i] <- join_pages(unique_letter[i], min_num[i], max_num[i])
  }
  # delete helpvectors
  rm(unique_letter)
  rm(min_num)
  rm(max_num)
  # return output
  return(page)
}

# text: clean text
congress_stopword <- c("absent", "adjourn", "ask", "can", "chairman", "committee", "con", "democrat", "etc", "gentle ladies",
                       "gentle lady", "gentle man", "gentle men", "gentle woman", "gentle women",
                       "here about", "here after", "here at", "here by", "here in", "here of", "here on", "here to", "here under", "here upon", 
                       "here with", "month", "mr", "mrs", "ms", "nai", "nay", "none", "now", "part", "per",
                       "pro", "say", "senator", "shall", "sir", "speak", "speaker", "tell", "thank",
                       "there about", "there after", "there against", "there at", "there before",
                       "thereby", "there for", "there fore", "there from", "there in", "there of", "there on", "there to",
                       "there under", "there unto", "there upon", "there with",
                       "today", "where about", "where after", "whereas", "where at", "whereby", "where fore", "where from", "where in",
                       "where into", "where of", "where on", "where to", "where under",
                       "where upon", "wherever", "where with", "will", "yea", "yes", "yield")
#credits: Matthew Gentzkow,Jesse M. Shapiro, Matt Taddy (11/02/2019)
# http://web.stanford.edu/~gentzkow/research/politext.pdf

clean_text <- function(string){
  # remove \r
  string <- str_replace_all(string,pattern = "\r", " ")
  # remove \n
  string <- str_replace_all(string,pattern = "\n", " ")
  # remove punctuation and special signs
  string <- str_remove_all(string, pattern = "[[:punct:]]")
  # make strings lower case
  string <- str_to_lower(string, locale = "en")
  # remove multiple white spaces
  string <- str_replace_all(string,pattern = "[\\s]+", " ")
  # remove stopwords from package and from hand-collected list
  string <- removeWords(string, stopwords("english"))
  string <- removeWords(string, congress_stopword)
  string <- as.character(string)
}

# clean_all: combine all helperfunction in one function 
clean_all <- function(vol_no_date, unit, pages, text){
  vol <- clean_vol(vol_no_date)
  no <- clean_no(vol_no_date)
  date <- clean_date(vol_no_date)
  unit <- clean_unit(unit)
  pages <- clean_pages(pages)
  text <- clean_text(text)
  clean_data <- data.frame(vol, no, date, unit, pages, text, stringsAsFactors = FALSE)
  return(clean_data)
}

## apply helpferfunction to clean dataset
mydata_clean <- clean_all(mydata_sum$vol_no_date, 
                          mydata_sum$unit, 
                          mydata_sum$pages, 
                          mydata_sum$text)

write.csv(mydata_clean, "C:/Users/Simone/Desktop/UScongress_record_clean.csv") 

## ADD ON: remaining things to do ----------------------------
# - error handeling --> function should tell what they do!

# - directories: Assumption that wd is [~/output/.../html] --> is this always the case?
## tw: I corrected that using list.files

# - scrape_csrc.R --> possible that the output will be saved always in [~/output]?
## tw: yes programmed that way
