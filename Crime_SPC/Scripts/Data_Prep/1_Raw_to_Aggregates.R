
### This Script calls upon a variety of functions to prepare and manipulate the raw data to other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")
library(dplyr)

# Read in our raw data file saved in the "Data" folder
historical <- read.csv(file = "Data/User_Data/Historical_Raw_Data.csv", 
                       header = TRUE, 
                       stringsAsFactors = TRUE) %>%
  mutate(CrimeType = gsub(x = CrimeType, pattern = "/", replacement = "_"),
         Section = gsub(x = Section, pattern = "/", replacement = "_"))

# Create aggregate tables
weekly_section_data <- Create_Weekly_Aggregate(data_input = historical, city_wide = FALSE)
weekly_citywide_data <- Create_Weekly_Aggregate(data_input = historical, city_wide = TRUE)
yearly_section_data <- Create_Yearly_Aggregate(data_input = historical, city_wide = FALSE)
yearly_citywide_data <- Create_Yearly_Aggregate(data_input = historical, city_wide = TRUE)

# Save data tables to the "Data" Folder

# Weekly Section Level
write.csv(x = weekly_section_data, 
          file = "Data/Data_Prep/Aggregate_Data_Weekly_Section.csv", 
          row.names = FALSE)

# Weekly Citywide Level
write.csv(x = weekly_citywide_data, 
          file = "Data/Data_Prep/Aggregate_Data_Weekly_Citywide.csv", 
          row.names = FALSE)

# Yearly Section Level
write.csv(x = yearly_section_data, 
          file = "Data/Data_Prep/Aggregate_Data_Yearly_Section.csv", 
          row.names = FALSE)

# Yearly Citywide
write.csv(x = yearly_citywide_data, 
          file = "Data/Data_Prep/Aggregate_Data_Yearly_Citywide.csv", 
          row.names = FALSE)
