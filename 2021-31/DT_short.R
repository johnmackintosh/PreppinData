library(here)
library(data.table)
setwd(here("2021-31"))

DT <- fread(cmd = paste("grep", " Sold ", "Input.csv"), drop = c(1,4)) # drop Date and Status cols
setnames(DT, new = c('Store', 'Item', 'Sales'))
DT <- dcast(DT, Store ~ Item, value.var = 'Sales', fun.aggregate = sum)
DT[,'Items Sold per Store' := rowSums(.SD), by = Store]
DT[,.(`Items Sold per Store`, Wheels, Tyres, Saddles, Brakes, Store)][]
fwrite(DT,"DT.csv")
