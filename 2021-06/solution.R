library(readxl)
library(data.table)
data <- read_excel("2021-06/PGALPGAMoney2019.xlsx", 
        col_types = c("text", "numeric", "numeric", "text"))

DT <- setDT(copy(data))
oldnames <- names(DT)
newnames = c('player', 'money', 'events', 'tour')
setnames(DT, old = oldnames, new = newnames)

DT[, count := .N, by = player][]
DT[,`:=`(Total_Prize_Money = sum(money),
         Number_of_Players = sum(count),
         Number_of_Events = sum(events),
         tour_rank = frank(-money)), by = tour][]

DT[,avg_per_event := money / events, by = player]
DT[, total_rank := frank(-money)]
DT[,Avg_Money_Per_Event := mean(avg_per_event), by = tour][]

DT[,rank_variance := total_rank - tour_rank, by = player][]
DT[,Avg_Difference_in_Ranking := mean(rank_variance), by = tour][]

DT <- unique(DT[,-c('player','money', 'events','count','avg_per_event',
              'tour_rank','total_rank','rank_variance')])[]

output <- melt(DT)
output <- dcast(output, variable ~ tour) # figuring this out was the hardest part
setcolorder(output,c('variable', 'PGA', 'LPGA')) 
output[,difference_between_tours := LPGA - PGA]
output[order(-variable)][]
