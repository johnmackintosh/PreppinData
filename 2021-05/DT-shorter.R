    library(data.table) 
    library(here)
    library(janitor)
    setwd(here("2021-05"))
    
    DT <- clean_names(fread("Joined Dataset.csv"))
    DT[, from_date := as.IDate(DT$from_date, format = "%d/%m/%Y")]
    
    # find latest account manager
    
    DT[,latest_date := max(from_date), by = .(client)][] # get latest date
    
    # on the latest date for each client, who was the AM and what was the client ID?
    am_lookup <- DT[from_date == latest_date, .(account_manager,client_id), 
                     by = .(client)][]
    am_lookup <- unique(am_lookup)
    
    # join and update account manager, client_id and original from date
    
    DT[am_lookup, client_id := i.client_id, on = "client"]
    
    DT[am_lookup, account_manager := i.account_manager, on = "client"]
    
    DT[,from_date := latest_date, by = .(client)][,latest_date := NULL][]
    
    output <- unique(DT)
    # check results match the expected output
    results <- clean_names(fread("results.csv")) # the sample output provided
    results[, from_date := as.IDate(results$from_date, format = "%d/%m/%Y")]
    
    # should be 0
    fsetdiff(results, output)
    
    outputs <- fwrite(output,"output.csv")
