# SPOSM - scraper
# simone euler, tobias witter


# function zip by link and unzip only html files,store them as output
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


### END OF CODE ###