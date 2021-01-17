library(here)
library(data.table) 
library(stringr)

setwd(here("2021-02"))

# read in and process

DT <- fread('Input.csv')


DT[,`:=`(`Order Date` = as.IDate(DT$`Order Date`, format = "%d/%m/%Y"),
          `Shipping Date` = as.IDate(DT$`Shipping Date`, format = "%d/%m/%Y"))]
DT[, Model := str_replace_all(DT$Model, "[^:A-Za-z:]", "")]

DT[, Order_Value := `Value per Bike` * Quantity]

DT[, days_to_ship := `Shipping Date` - `Order Date`,]




# create tables 1 and 2

output1  <- DT[,.SD,.SDcols = c('Model','Bike Type', 'Quantity', 
                                'Order_Value', 'Value per Bike')]


output1[, `:=`(Quantity = sum(Quantity), 
                Order_Value = sum(Order_Value),
                Avg_Value = mean(`Value per Bike`,na.rm = TRUE)), 
                                                    by = .(Model, `Bike Type`)]
output1[, Avg_Value := round(Avg_Value,1)]
output1[, `Value per Bike` := NULL]
output1 <- unique(output1)
setnames(output1, old = 'Model', new = 'Brand')


##  output 2

output2  <- DT[,.SD,.SDcols = c('Model','Store', 'Quantity', 
                                'Order_Value', 'days_to_ship')]

output2[, `:=`(Quantity = sum(Quantity), 
               Order_Value = sum(Order_Value),
               Avg_Days_to_Ship = mean(days_to_ship,na.rm = TRUE)), 
                                                        by = .(Model, Store)]

output2[, Avg_Days_to_Ship := round(Avg_Days_to_Ship,1)]

output2$days_to_ship <- NULL

output2 <- unique(output2)

setnames(output2, old = 'Model', new = 'Brand')


# checks

dim(output1)
str(output1)

dim(output2)
str(output2)



output1 <- fwrite(output1,"2021-02-output1.tsv", sep = "\t")
output2 <- fwrite(output2,"2021-02-output2.tsv", sep = "\t")



