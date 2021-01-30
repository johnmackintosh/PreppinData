library(readxl)
library(purrr)
library(data.table)
library(splitstackshape)

library(here)
setwd(here("2021-03"))


wb <- "PD 2021 Wk 3 Input.xlsx"

all_sheets <- wb %>%
    excel_sheets() %>%
    set_names()

data <-  map_dfr(all_sheets,
                 ~ read_excel(wb, sheet = .x),
                 .id = "sheet")

setnames(setDT(data),old ='sheet', new = 'Store')

DT <- melt(data,id.vars = c('Store','Date'), variable.factor = FALSE)
setnames(DT <- cSplit(DT, splitCols = "variable", sep = "-", direction = 'wide'),
         old = c('variable_1', 'variable_2'), new = c('Customer_Type','Product'))
DT[,Quarter := quarter(Date)][,Date := NULL][]


out1 <- unique(DT[,.SD, .SDcols =c('Product','Quarter','value')
           ][,ProductQuarterSales := sum(value),by = .(Product, Quarter)
             ][,value := NULL])[]

out2 <- unique(DT[,.SD, .SDcols =c('Product','Customer_Type','Store','value')
                  ][,Sales := sum(value),by = .(Product, Customer_Type, Store)
                    ][,value := NULL])[]
