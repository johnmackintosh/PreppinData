library(here)
library(dplyr)
library(readr)
library(tidyr)

setwd(here("2021-31"))

sales <- read_csv("Input.csv", 
                 col_types = cols(Date = col_date(format = "%d/%m/%Y")))
                                                                                  

sales <- sales %>% 
    filter( Status != "Return to Manufacturer")

totals <- sales %>% 
    group_by(Store) %>% 
    summarise(`Items Sold per Store` = sum(`Number of Items`))


sales <- sales %>% 
    select(-c('Status','Date')) %>% 
    group_by( Store, Item) %>% 
    summarise(N = sum(`Number of Items`)) %>% 
    spread(key = 'Item', value = 'N') %>% 
    left_join(totals, by = 'Store') %>% 
    select(`Items Sold per Store`, Wheels, Tyres, Saddles, Brakes, Store)

data.table::fwrite(sales,"sales.csv")
