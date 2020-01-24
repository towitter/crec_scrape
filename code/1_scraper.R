# SPOSM
# simone euler, tobias witter

# packages
lib <- c("tidyverse", "lubridate", "data.table") 

#lapply(lib, install.packages)
lapply(lib, require, character.only = T)

'%ni%' <- Negate('%in%')

# dates we want to download the records for
start_date <- ymd("2013-01-26")
end_date <- ymd("2013-01-31")

# base url for zipped files
base_url <- "https://www.govinfo.gov/content/pkg/CREC-"
end_url <- paste0(seq(start_date, end_date, 1), ".zip")

# scrape zip file url
zip_url <- paste0(base_url, end_url)

# function zip by link and unzip only html files,
# store them as output
download_unzip_extract_html <- function(x){
  
  # temporary store
  temp <- tempfile()
  
  # read all files in temp
  download.file(x, temp)
  
  # unzip and read html files
  html_to_unzip <- grep('\\.htm$', unzip(temp, list=TRUE)$Name,
                    ignore.case=TRUE, value=TRUE)
  
  unzip(temp, files = html_to_unzip, exdir = "output")

  # function does not return values
}


# function gets wrapped in trycatch to prevent function from stopping at an error,
# gives a warning instead
get_htmls <- function(x){
  tryCatch(download_unzip_extract_html(x),
           error = function(e){
             warning(paste("No resources for that day:", x));NA
             })
  }


# apply function for test period
for(i in seq_along(zip_url)){
  get_htmls(zip_url[i])
}






# here...








# unzip and read html files
rec_dat <- temp %>% unz(., paste0("crec_from", start_date, "_to_", end_date))

# use string split between start_of_doc and end_of_doc
start_of_doc <- "<body><pre>"
end_of_doc <- "</pre></body>"