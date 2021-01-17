library(data.table) 
library(gsheet)
library(ggplot2)

link <- 'https://docs.google.com/spreadsheets/d/1GYv4573GnJa-C21NYeDj-OhFSTwrK0SnQNF2IQFqa50/edit#gid=0'

import <- gsheet2text(link, format = 'tsv')

DT <- fread(import)
DT[, Date := as.IDate(DT$Date, format = "%d/%m/%Y")]
DT[, c("Store", "Bike") := tstrsplit(`Store - Bike`, " - ", fixed = TRUE)][,`Store - Bike` := NULL]
DT[,first := trimws(substr(Bike,1,1)),]
DT[,Bike := fcase( first == 'R', "Road", first == 'G', "Gravel", first == 'M', "Mountain")
   ][,first := NULL]
DT[,`:=`(Quarter =  quarter(Date),  Day_of_Month = mday(Date), Date = NULL)]
DT <- DT[-c(1:10),][]

output <- fwrite(DT,"2021-01-output.tsv")

# Bonus

DT[,daily_average := as.integer(lapply(.SD,mean)),.SDcols = "Bike Value",
   by = .(Quarter,Day_of_Month, Bike)][]

DT2 <- DT[,.SD,.SDcols = c('Bike','Quarter', 'Day_of_Month', 'daily_average')]

DT2 <- unique(DT2)

keycols <- c('Bike', 'Quarter', 'Day_of_Month')

setkeyv(DT2, keycols)


DT2[, cumulative := cumsum(daily_average), by = .(Quarter,Bike)][]

ggplot(DT2,aes(Day_of_Month,cumulative, colour = Bike)) +
    geom_line() + 
    facet_wrap(~ Quarter, ncol = 2) +
    labs(x = 'Day of Month', y = 'Cumulative Avg Daily Bike Value') +
    theme_minimal() +
    theme(legend.position = 'bottom')

