library(here)
library(data.table)
setwd(here("2021-31"))

DT <- fread(cmd = paste("grep", " Sold ", "Input.csv"), drop = c(1,4),
            col.names = c("Store","Item","Sales")) # drop Date & Status, rename Sales
DT <- dcast(DT, Store ~ Item, value.var = 'Sales', fun.aggregate = sum) # PIVOT!
DT[,'Items Sold per Store' := rowSums(.SD), by = Store] # Totals by Store
DT[,.(`Items Sold per Store`, Wheels, Tyres, Saddles, Brakes, Store)][] # or use setcolorder()
fwrite(DT,"DT2.csv")
