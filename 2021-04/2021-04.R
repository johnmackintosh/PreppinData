library(lubridate)
library(dplyr)
library(tidyr)
library(readxl)
library(purrr)
library(here)
setwd(here("2021-04"))


wb <- "PD 2021 Wk 4 Input.xlsx"
all_sheets <- wb %>%
    excel_sheets() %>%
    set_names()

datasheets <- all_sheets[which(!all_sheets %in% c('Targets'))]

data <-  map_dfr(datasheets,
                 ~ read_excel(wb, sheet = .x),
                 .id = "sheet") %>% 
    rename(Store = sheet)


targets <- read_excel(wb, sheet = 'Targets')

store_data <- data %>% 
    gather('metric','Products_Sold', -c(Store, Date)) %>% 
    separate(.,metric, sep = ' - ', into = c('Customer_Type','Product')) %>% 
    mutate(Quarter = quarter(Date))

out1 <- store_data %>% 
    group_by(Store, Quarter) %>% 
    summarise(`Products Sold` = sum(Products_Sold), .groups = 'keep')

out2 <- out1 %>% 
    left_join(.,targets, by = c('Store','Quarter')) %>% 
    mutate(Variance_to_Target = `Products Sold` - Target) %>%
    group_by(Quarter) %>% 
    arrange(Quarter, desc(Variance_to_Target)) %>% 
    mutate(Store_Rank = row_number()) %>% 
        ungroup()


write.csv(out2,'Store_Rank_by_Quarter.csv')
