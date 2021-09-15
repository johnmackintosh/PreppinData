library(data.table) 
library(gsheet)
library(lubridate)
library(patientcounter)
link <- 'https://docs.google.com/spreadsheets/d/1LOe-rvVr2Dea6ftdLFZ3hMQfAPBPRqOQ/edit#gid=154472524'

# import, improve the column names and set as datetime for the intervalcensus function

import <- gsheet2text(link, format = 'csv')
DT <- fread(import)

old <- names(DT)
new <- c("Name", "Cost","ContractLength","StartDate")
setnames(DT, old = old, new = new)

DT[, Date := as.IDate(StartDate, format = "%d/%m/%Y")]
DT[is.na(Date), Date := as.Date('2019-02-22')]
DT[, EndDate := Date %m+% months(ContractLength)]
DT[, Date := as.POSIXct(Date)]
DT[, EndDate := as.POSIXct(EndDate)]

# create one row per month per customer 
res <- interval_census(DT, identifier = 'Name', 
                       admit = 'Date', 
                       discharge = 'EndDate', 
                       time_unit = '30 days', 
                       results = 'patient')

cols_to_keep <- c("Name","Cost","Date","base_date", "CumulativeMonthly")
res <- res[,CumulativeMonthly := cumsum(Cost), Name
           ][,.SD, .SDcols = cols_to_keep
             ]

res[,payment_date := make_date(year = year(base_date), 
                               month = month(base_date), 
                               day = day(Date))
    ][,`:=`(Date = NULL, base_date = NULL)][order(Name)][]

fwrite(res,"output.csv")
