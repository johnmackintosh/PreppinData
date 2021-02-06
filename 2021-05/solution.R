library(data.table) 
library(here)
library(janitor)
library(dplyr)
setwd(here("2021-05"))

DT <- clean_names(fread("Joined Dataset.csv"))
DT[, from_date := as.IDate(DT$from_date, format = "%d/%m/%Y")]

DT2 <- copy(DT) # so we don't have to reload if all goes wrong

# find latest account manager

DT2[,latest_date := max(from_date), by = .(client)][] # get latest date

# on the latest date for each client, who was the AM and what was the client ID?
am_lookup <- DT2[from_date == latest_date, .(account_manager,client_id), 
                 by = .(client)][]
am_lookup <- unique(am_lookup)

#  prepare for joining and do the lookup

DT2[,join_col := client][]
am_lookup[,join_col := client][]

setkey(DT2,'join_col')
setkey(am_lookup,'join_col')

DT2 <- am_lookup[DT2]

# delete the original columns that are innacurate, plus the join column
DT2[,`:=`(from_date = NULL, i.account_manager = NULL, 
          i.client_id = NULL, i.client = NULL, join_col = NULL)][] 

# rename and reset the column order
setnames(DT2, old = c('latest_date'), new = c('from_date'))
setcolorder(DT2,c('training','contact_email','contact_name','client',
                  'client_id','account_manager', 'from_date'))
rm(am_lookup) # tidy up

# get the uniques
DT2 <- unique(DT2)


# check results match the expected output
results <- clean_names(fread("results.csv")) # the sample output provided
results[, from_date := as.IDate(results$from_date, format = "%d/%m/%Y")]

# should be 0
fsetdiff(results, DT2)
#Empty data.table (0 rows and 7 cols): training,contact_email,contact_name,client,client_id,account_manager...

