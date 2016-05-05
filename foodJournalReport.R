#----------------------------------------------------------------------------- SETUP -

# checking for required packages, installing if necessary
reqPackages <- c("googlesheets", "magrittr", "dplyr", "httpuv", "lubridate", "tidyr", "ggplot2")
newPackages <- reqPackages[!(reqPackages %in% installed.packages()[,"Package"])]
if(length(newPackages)) install.packages(newPackages)

# load the required packages

invisible(sapply(reqPackages, library, character.only = TRUE))

# clean up variables used to load packages

rm(reqPackages, newPackages)

# registering the Google Sheet we would like to work with and pulling the data

journalData <- gs_title("Food Journal (Responses)") %>% gs_read()

# now for the data munging to get things in a good state for graphing

# selecting only the data we need
journalData <- journalData[,c(1,2,6,11)]

# --- DATES, TIMES, and DURATIONS ---

# splitting timestamp into date and start times
journalData <- journalData %>% separate(Timestamp, c("date", "mealStart"), " ")

# converting duration to a factor variable
colnames(journalData)[5] <- "duration" # for programmatic ease
journalData$duration[journalData$duration == "< 15 minutes"] <- 15
journalData$duration[journalData$duration == "15 - 30 minutes"] <- 30
journalData$duration[journalData$duration == "31 - 45 minutes"] <- 45
journalData$duration[journalData$duration == "46 - 60 minutes"] <- 60
journalData$duration[journalData$duration == "> 60 minutes"] <- 90

# creating new mealend column
journalData$mealEnd <- hms(journalData$mealStart) + minutes(journalData$duration)

# normalizing the other date/time columns
journalData$mealStart <- hms(journalData$mealStart)
journalData$date <- mdy(journalData$date)

# --- HUNGER RATINGS ---

# renaming the hunger columns and truncating just the number
colnames(journalData)[3:4] <- c("hunger", "satiety")
journalData[,3] <- sapply(journalData[,3], substr, start = 1, stop = 1)
journalData[,4] <- sapply(journalData[,4], substr, start = 1, stop = 1)


# --- SUBSETTING BY DATE ---
# right now, this report will be run weekly, and we'll want to compare two weeks of data
journalData <- journalData[journalData$date %within% interval(today() - dweeks(2), today()),]

lastWeekJournalData <- journalData[journalData$date %within% 
                                       interval(today() - dweeks(1), today()),]
prevWeekJournalData <- journalData[journalData$date %within% 
                                       interval(today() - dweeks(2), today() - dweeks(1)),]

# --- PRODUCING PLOTS ---

