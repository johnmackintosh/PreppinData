library(lubridate)
library(dplyr)
library(tidyr)
library(readxl)
library(purrr)

library(here)
setwd(here("2021-03"))


wb <- "PD 2021 Wk 3 Input.xlsx"
all_sheets <- wb %>%
    excel_sheets() %>%
    set_names()


data <-  map_dfr(all_sheets,
                 ~ read_excel(wb, sheet = .x),
                 .id = "sheet") %>% 
    rename(Store = sheet)

store_data <- data %>% 
    gather('metric','Products_Sold', -c(Store, Date)) %>% 
    separate(.,metric, sep = ' - ', into = c('Customer_Type','Product')) %>% 
    mutate(Quarter = quarter(Date))
    

out1 <- store_data %>% 
    group_by(Product, Quarter) %>% 
    summarise(`Products Sold` = sum(Products_Sold), .groups = 'keep')

out2 <- store_data %>% 
    group_by(Store, Customer_Type, Product) %>% 
    summarise(`Products Sold` = sum(Products_Sold), .groups = 'keep')

write.csv(out1,'Product_Quarter_Output.csv')
write.csv(out2,'Store_Customer_Product_Output.csv')

