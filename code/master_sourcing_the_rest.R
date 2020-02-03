# SPOSM - master
# simone euler, tobias witter

# dates we want to download the records for
#start_date <- ymd("2012-07-01")
#end_date <- ymd("2013-06-30")

# from here... from 2013-05-19
start_date <- ymd("2013-05-19")
end_date <- ymd("2013-06-30")

system.time(
  source("code/1_scraper.R")
  )

save_warnings <- warnings()