library(readxl)
library(purrr)
library(data.table)
library(splitstackshape)

library(here)
setwd(here("2021-04"))


wb <- "PD 2021 Wk 4 Input.xlsx"
all_sheets <- wb %>%
    excel_sheets() %>%
    set_names()

datasheets <- all_sheets[which(!all_sheets %in% c('Targets'))]

targets <- read_excel(wb, sheet = 'Targets')
setDT(targets)

data <-  map_dfr(datasheets,
                 ~ read_excel(wb, sheet = .x),
                 .id = "sheet")

setnames(setDT(data),old = 'sheet', new = 'Store')



DT <- melt(data,id.vars = c('Store','Date'), variable.factor = FALSE)
setnames(DT <- cSplit(DT, splitCols = "variable", sep = "-", direction = 'wide'),
         old = c('variable_1', 'variable_2'), new = c('Customer_Type','Product'))
DT[,Quarter := quarter(Date)][,Date := NULL][]

DT[,Products_Sold := sum(value), by = .(Store, Quarter)]

out2 <- unique(DT[,`:=`(value = NULL, Customer_Type = NULL, Product = NULL)])[]

# create a join key

out2[, joinkey := paste0(Store,Quarter,sep = '_')][]
targets[, joinkey := paste0(Store,Quarter,sep = '_')][]

out2 <- targets[out2, on = 'joinkey'][,':='(joinkey = NULL,
                                  i.Store = NULL,
                                  i.Quarter = NULL)]

out2[,variance := Products_Sold - Target][]

setorder(out2, Quarter, -variance)

out2[,rank := frank(-variance), by = Quarter][]

