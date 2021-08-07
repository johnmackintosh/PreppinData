library(here)
library(data.table)
setwd(here("2021-31"))

DT <- fread("Input.csv")
DT[, Date := as.IDate(DT$Date, format = "%d/%m/%Y")]
DT <- DT[Status %chin% 'Sold',][]

Totals <- copy(DT)
Totals[,.(Store,`Number of Items`)][]
Totals <- Totals[, .('Total' = sum(`Number of Items`)), by = Store][]

DT <- DT[,-c('Status', 'Date')
         ][,.(Sales = sum(`Number of Items`)), by = .(Store,Item)][]
DT <- DT[,.(Store, Item,Sales)][]

DT <- dcast(DT,Store~Item,value.var = 'Sales', fun.aggregate = sum)
DT <- Totals[DT,  on = 'Store'][]  
setnames(DT, old = 'Total', new = 'Items Sold per Store')
DT[,.(`Items Sold per Store`, Wheels, Tyres, Saddles, Brakes, Store)][]

fwrite(DT,"DT.txt", sep = "\t")
