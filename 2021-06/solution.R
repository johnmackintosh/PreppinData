library(readxl)
library(data.table)
library(janitor)

data <- read_excel("2021-06/PGALPGAMoney2019.xlsx", 
        col_types = c("text", "numeric", "numeric", "text")) %>% 
    janitor::clean_names()

DT <- setDT(copy(data))
DT[,count := as.double(1L)][]
DT[,`:=`(Total_Prize_Money = sum(money),
         Number_of_Players = sum(count),
         Number_of_Events = sum(events),
         tour_rank = frank(- money)), by = tour]
DT[,avg_per_event := money / events, by = player_name]
DT[,total_rank := frank(- money)]
DT[,Avg_Money_Per_Event := mean(avg_per_event), by = tour]
DT[,rank_variance := total_rank - tour_rank, by = player_name]
DT[,Avg_Difference_in_Ranking := mean(rank_variance), by = tour]

keepnames <- c('tour','Total_Prize_Money', 'Number_of_Players', 
'Number_of_Events', 'Avg_Money_Per_Event', 'Avg_Difference_in_Ranking')

measurevars <- keepnames[!keepnames %chin% 'tour']

DT <- unique(DT[,..keepnames])
DT <- melt(DT, id.vars = 'tour', measure.vars = measurevars)
DT <- dcast(DT, variable ~ tour) 
setcolorder(DT,c('variable', 'PGA', 'LPGA')) 
DT[,difference_between_tours := LPGA - PGA]
DT[order(-variable)][]
