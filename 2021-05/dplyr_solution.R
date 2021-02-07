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
    rename(lookup_am = account_manager, 
           lookup_id = client_id) %>% 
    distinct() 


DT <- full_join(DT, am_lookup, by = 'client') %>% 
    mutate(client_id = lookup_id, 
           account_manager = lookup_am,
           from_date = latest_date) %>% 
    select(-c('lookup_am','lookup_id','latest_date')) %>% 
    distinct() %>% 
    select(training, contact_email, contact_name,
           client, client_id, account_manager, from_date)
    

# check results match the expected output
results <- clean_names(read.csv("results.csv")) %>% 
    rename(training = i_training) 

results <- results %>% 
    mutate(from_date = lubridate::as_date(from_date,format = "%d/%m/%Y"))

# should be 0
setdiff(results, DT)
