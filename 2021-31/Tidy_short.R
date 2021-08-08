library(here)
library(readr)
library(dplyr)
library(tidyr)

setwd(here("2021-31"))

sales <- read_csv("Input.csv") %>% 
    filter(Status == "Sold") %>% 
    select(-c("Date", "Status")) %>% 
    group_by( Store, Item) %>% 
    summarise(N = sum(`Number of Items`)) %>% 
    spread(key = 'Item', value = 'N') %>% 
    mutate(`Items Sold per Store` = sum(c_across(where(is.numeric)))) %>% 
    select(`Items Sold per Store`, Wheels, Tyres, Saddles, Brakes, Store) %>% 
    data.table::fwrite("tidy2.csv")
                  
