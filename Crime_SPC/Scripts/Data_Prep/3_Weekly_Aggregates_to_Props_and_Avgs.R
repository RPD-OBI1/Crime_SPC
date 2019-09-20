### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")
library(dplyr)

# Read in aggregate tables made prior and saved in the "Data" folder
section_weekly_aggregate <- read.csv(file = "Data/Data_Prep/Aggregate_Data_Weekly_Section.csv",
                                     header = TRUE,
                                     stringsAsFactors = TRUE)

citywide_weekly_aggregate <- read.csv(file = "Data/Data_Prep/Aggregate_Data_Weekly_Citywide.csv",
                                      header = TRUE,
                                      stringsAsFactors = TRUE)

# Create Proportion tables. These tables show what proprtion of the crimetype occurred in a given "week" by aggregating all years to the week level

weekly_section_proportions <- Create_Weekly_Proportions(data_input = section_weekly_aggregate, 
                                                        number_of_years = 3)
weekly_citywide_proportions <- Create_Weekly_Proportions(data_input = citywide_weekly_aggregate, 
                                                         number_of_years = 3)

# Save data tables to the "Data" Folder

# Weekly Section Proportions
write.csv(x = weekly_section_proportions, 
          file = "Data/Data_Prep/Weekly_Proportions_Data_Section.csv", 
          row.names = FALSE)

# Weekly Citywide Proportions
write.csv(x = weekly_citywide_proportions, 
          file = "Data/Data_Prep/Weekly_Proportions_Data_Citywide.csv", 
          row.names = FALSE)
