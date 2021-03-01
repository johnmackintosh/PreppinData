library(readxl)
library(data.table)
library(lubridate)
library(here)

setwd(here("2021-08"))

choices <- setDT(read_excel("karaoke.xlsx", 
                            col_types = c("date","text", "text")))

customers <- setDT(read_excel("karaoke.xlsx", sheet = "Customers", 
                        col_types = c("text", "date")))

# create columns to join on, then sort
choices[,`:=` (join_time = Date)]; setkey(choices, join_time)
customers[,`:=` (join_time = `Entry Time`)];setkey(customers, join_time)


# create session number and cols to check that entry time within 10 mins of session start
choices[,lag_date := shift(Date, type = 'lag', fill = 1L)
        ][,new_session := difftime(Date,lag_date,'mins')>= 59
          ][,session_number := cumsum(new_session == TRUE)
            ][,song_number := rowid(session_number)
              ][,session_start := min(Date), by = session_number
                ][,entry_check := session_start - lubridate::minutes(10)
                  ][,`:=`(new_session = NULL, lag_date = NULL)]

merged <- customers[choices, roll = TRUE]
merged[!between(`Entry Time`,entry_check,session_start), `Customer ID` := NA]

setkey(merged,'Date','session_number','Customer ID','song_number')

my_output <- fwrite(merged[,c('session_number','Customer ID', 'song_number','Date','Artist','Song')],"final_output.csv")




