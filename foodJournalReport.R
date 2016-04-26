#----------------------------------------------------------------------------- SETUP -

# checking for required packages, installing if necessary
reqPackages <- c("googlesheets", "magrittr", "dplyr", "httpuv", "lubridate")
newPackages <- reqPackages[!(reqPackages %in% installed.packages()[,"Package"])]
if(length(newPackages)) install.packages(newPackages)

# load the required packages

invisible(sapply(reqPackages, library, character.only = TRUE))

# clean up variables used to load packages

rm(reqPackages, newPackages)

# registering the Google Sheet we would like to work with and pulling the data

journalData <- gs_title("Food Journal (Responses)") %>% gs_read(col_names = FALSE)
