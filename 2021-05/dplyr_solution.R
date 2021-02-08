library(dplyr) 
library(here)
library(janitor)
library(lubridate)
setwd(here("2021-05"))

DT <- clean_names(read.csv("Joined Dataset.csv")) %>% 
    rename(training = i_training) %>% 
    mutate(from_date = lubridate::as_date(from_date,format = "%d/%m/%Y"))

# find latest account manager- first, latest date by client
DT <- DT %>% 
    group_by(client) %>% 
    mutate(latest_date = max(from_date)) %>% 
    ungroup()

# on the latest date for each client, who was the AM and what was the client ID?
am_lookup <- DT %>% 
    group_by(client) %>% 
    filter(from_date == latest_date) %>% 
    select(client,account_manager, client_id) %>% 
    distinct() 


DT <- DT %>% 
    select(-c('account_manager', 'client_id')) %>% 
    left_join(., am_lookup, by = 'client') %>% 
    mutate(from_date = NULL) %>% 
    rename(from_date = latest_date) %>% 
    relocate(from_date, .after = last_col()) %>% 
    distinct()
    

# check results match the expected output
results <- clean_names(read.csv("results.csv")) %>% 
    rename(training = i_training) 

results <- results %>% 
    mutate(from_date = lubridate::as_date(from_date,format = "%d/%m/%Y"))

# should be 0
setdiff(results, DT)
