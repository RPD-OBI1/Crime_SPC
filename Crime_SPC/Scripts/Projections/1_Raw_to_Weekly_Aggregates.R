
### This Script calls upon a variety of functions to prepare and manipulate the raw data to other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")
library(dplyr)

# Read in bounds to gather all sections and crimetypes possible to account for everything.

aggregate_yearly_section <- read.csv("Data/Data_Prep/Aggregate_Data_Yearly_Section.csv",
                                     header = TRUE,
                                     stringsAsFactors = TRUE)

sec <- as.character(unique(aggregate_yearly_section$Section))
crm <- as.character(unique(aggregate_yearly_section$CrimeType))

# Read in our raw data file saved in the "Data" folder
curr_year <- read.csv(file = "Data/User_Data/Current_Year_Raw_Data.csv", 
                      header = TRUE, 
                      stringsAsFactors = FALSE) %>%
  mutate(CrimeType = gsub(x = CrimeType, pattern = "/", replacement = "_"),
         Section = gsub(x = Section, pattern = "/", replacement = "_")) %>%
  mutate(Section = factor(Section, levels = sec),     # Make factors to account for all combinations found in the bounds file
         CrimeType = factor(CrimeType, levels = crm))

# Create aggregate tables
weekly_section_data <- Create_Weekly_Aggregate(data_input = curr_year, city_wide = FALSE)
weekly_citywide_data <- Create_Weekly_Aggregate(data_input = curr_year, city_wide = TRUE)

# Save data tables to the "Data" Folder

# Weekly Section Level
write.csv(x = weekly_section_data, 
          file = "Data/Projections/Current_Weekly_Section.csv", 
          row.names = FALSE)

# Weekly Citywide Level
write.csv(x = weekly_citywide_data, 
          file = "Data/Projections/Current_Weekly_Citywide.csv", 
          row.names = FALSE)
