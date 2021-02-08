library(readxl)
library(purrr)
library(data.table)
library(here)
setwd(here("2021-04"))

wb <- "PD 2021 Wk 4 Input.xlsx"
all_sheets <- wb %>%
    excel_sheets() %>%
    set_names()

datasheets <- all_sheets[which(!all_sheets %in% c('Targets'))]

targets <- setDT(read_excel(wb, sheet = 'Targets'))

data <-  setDT(map_dfr(datasheets,
                 ~ read_excel(wb, sheet = .x),
                 .id = "Store"))

DT <- melt(data,id.vars = c('Store','Date'), variable.factor = FALSE)
DT[, c("Customer_Type", "Product") := tstrsplit(`variable`, " - ", fixed = TRUE)][,variable := NULL]

DT[,Quarter := quarter(Date)][,Date := NULL][]
DT[,Products_Sold := sum(value), by = .(Store, Quarter)]

out2 <- unique(DT[, -c('value','Customer_Type', 'Product')])

# join with the targets, and calculate variance
out2 <- targets[out2, on = c('Store','Quarter')][,variance := Products_Sold - Target][]

setorder(out2, Quarter, -variance) #order by variance in descending order
out2[,rank := frank(-variance), by = Quarter][]  # rank by variance in descending order
fwrite(out2,"output2DT.csv")
