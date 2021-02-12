library(readxl)
library(dplyr)
library(tidyr)
library(janitor)

data <- read_excel("PGALPGAMoney2019.xlsx", 
col_types = c("text", "numeric", "numeric", "text")) %>% 
    janitor::clean_names()


data <- data %>% 
    mutate(count = 1L) %>% 
    group_by(tour) %>% 
    mutate(Total_Prize_Money = sum(money),
           Number_of_Players = sum(count),
           Number_of_Events = sum(events),
           tour_rank = rank(-money)) %>% 
    ungroup()

data <- data %>% 
    group_by(player_name) %>% 
    mutate(avg_per_event = money / events) %>% 
    ungroup()

data <- data %>% 
    mutate(total_rank = rank(-money))

data <- data %>% 
    group_by(tour) %>% 
    mutate(Avg_Money_Per_Event = mean(avg_per_event)) %>% 
    ungroup()

data <- data %>% 
    group_by(player_name) %>% 
    mutate(rank_variance = (total_rank - tour_rank)) %>% 
    ungroup()

data <- data %>% 
    group_by(tour) %>% 
    mutate(Avg_Difference_in_Ranking = mean(rank_variance)) %>% 
    ungroup()

   
data <- data %>% 
    select(tour, Total_Prize_Money, Number_of_Players, Number_of_Events,
           Avg_Money_Per_Event, Avg_Difference_in_Ranking) %>% 
    distinct()

output <- pivot_longer(data, -tour, names_to = 'Measure', 
                       values_to = 'Value') %>% 
    pivot_wider(., names_from = 'tour', id_cols = 'Measure', 
                values_from = 'Value') %>% 
    mutate(Difference_Between_Tours = LPGA - PGA) %>% 
    arrange(Measure)

