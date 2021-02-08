library(readxl)
library(purrr)
library(data.table)
library(here)
setwd(here("2021-03"))

wb <- "PD 2021 Wk 3 Input.xlsx"

all_sheets <- wb %>%
    excel_sheets() %>%
    set_names()

data <-  map_dfr(all_sheets,
                 ~ read_excel(wb, sheet = .x),
                 .id = "Store")

DT <- melt(setDT(data),id.vars = c('Store','Date'), variable.factor = FALSE)

DT[, c("Customer_Type", "Product") := tstrsplit(`variable`, " - ", fixed = TRUE)
   ][,variable := NULL]

DT[,Quarter := quarter(Date)][,Date := NULL][]

out1 <- unique(DT[,c('Product','Quarter','value')][,ProductQuarterSales := sum(value),by = .(Product, Quarter)][,value := NULL])[]

out2 <- unique(DT[,c('Store','Customer_Type','Product','value')][,Sales := sum(value),by = .(Product, Customer_Type, Store)][,value := NULL])[]
