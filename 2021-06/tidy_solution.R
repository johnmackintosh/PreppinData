library(readxl)
library(dplyr)
library(tidyr)
data <- read_excel("2021-06/PGALPGAMoney2019.xlsx", 
                   col_types = c("text", "numeric", "numeric", "text"))

data <- data %>% 
    rename(player = `PLAYER NAME`,
            money = MONEY,
            events = EVENTS,
            tour = TOUR) %>% 
    mutate(count = 1L) %>% 
    group_by(tour) %>% 
    mutate(Total_Prize_Money = sum(money),
           Number_of_Players = sum(count),
           Number_of_Events = sum(events),
           tour_rank = rank(-money)) %>% 
    ungroup()

data <- data %>% 
    group_by(player) %>% 
    mutate(avg_per_event = money / events) %>% 
    ungroup()

data <- data %>% 
    mutate(total_rank = rank(-money))

data <- data %>% 
    group_by(tour) %>% 
    mutate(Avg_Money_Per_Event = mean(avg_per_event)) %>% 
    ungroup()

data <- data %>% 
    group_by(player) %>% 
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

output <- gather(data, key = 'Measure', value = 'Value', - tour) %>% 
    pivot_wider(., names_from = 'tour', 
                id_cols = 'Measure', 
                values_from = 'Value') %>% 
    mutate(Difference_Between_Tours = LPGA - PGA) %>% 
    arrange(Measure)

