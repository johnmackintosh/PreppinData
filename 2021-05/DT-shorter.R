library(data.table) 
library(here)
library(janitor)
    
setwd(here("2021-05"))
    
DT <- clean_names(fread("Joined Dataset.csv"))
DT[, from_date := as.IDate(DT$from_date, format = "%d/%m/%Y")]
 
# on the latest date for each client, who was the AM /  what's their client ID?   
DT[,latest_date := max(from_date), by = .(client)][]  # latest date by client
am_lookup <- DT[from_date == latest_date, .(account_manager,client_id), 
                by = .(client)][]
am_lookup <- unique(am_lookup) # look-up of unique values for joining
    
# join and update account manager, client_id and original 'from date', then de-dupe
DT[am_lookup, `:=` (client_id = i.client_id,
                   account_manager = i.account_manager), on = 'client']
DT[,from_date := latest_date, by = .(client)][,latest_date := NULL][]
DT <- unique(DT)

# check results match the expected output, and write out to file
results <- clean_names(fread("results.csv")) # the sample output provided
results[, from_date := as.IDate(results$from_date, format = "%d/%m/%Y")]
fsetdiff(results, DT) # should be 0
outputs <- fwrite(DT,"output.csv") # all good, write the output
