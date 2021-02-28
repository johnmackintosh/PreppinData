library(readxl)
library(data.table)
library(lubridate)
library(here)

setwd(here("2021-08"))

choices <- read_excel("karaoke.xlsx", col_types = c("date","text", "text"))

customers <- read_excel("karaoke.xlsx", sheet = "Customers", 
                        col_types = c("text", "date"))

setDT(choices)
setDT(customers)

# create columns to join on, then sort
choices[,`:=` (join_time = Date)][]
customers[,`:=` (join_time = `Entry Time`)][]

setkey(choices, join_time)
setkey(customers, join_time)

# create session number and cols to check that entry time within 10 mins of session start
choices[,lag_date := shift(Date, type = 'lag', fill = 1L)]
choices[,new_session := difftime(Date,lag_date,'mins')>= 59]
choices[,session_number := cumsum(new_session == TRUE)]
choices[,song_number := rowid(session_number)]
choices[,session_start := min(Date), by = session_number]
choices[,entry_check := session_start - lubridate::minutes(10)]

choices[,`:=`(new_session = NULL, lag_date = NULL)]

test <- customers[choices, roll = TRUE]
test[!between(`Entry Time`,entry_check,session_start), `Customer ID` := NA]

my_output <- test[,c('session_number','Customer ID', 'song_number','Date','Artist','Song')]

setkey(test,'Date','session_number','Customer ID','song_number')

fwrite(my_output,"final_output.csv")
