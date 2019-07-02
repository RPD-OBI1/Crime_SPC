### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")

# Read in tables made prior and saved in the "Data" folder

# Weekly Proportions Tables
section_weekly_props <- read.csv("Data/Data_Prep/Weekly_Proportions_Data_Section.csv", 
                                  header = TRUE,
                                  stringsAsFactors = TRUE)

citywide_weekly_props <- read.csv("Data/Data_Prep/Weekly_Proportions_Data_Citywide.csv", 
                                  header = TRUE,
                                  stringsAsFactors = TRUE)

# Year-end Bounds Table
section_bound_values <- read.csv("Data/Data_Prep/Bound_Values_Data_Section.csv",
                                 header = TRUE,
                                 stringsAsFactors = TRUE)

citywide_bound_values <- read.csv("Data/Data_Prep/Bound_Values_Data_Citywide.csv",
                                  header = TRUE,
                                  stringsAsFactors = TRUE)

# Create weekly bounds

section_weekly_bounds <- Create_Weekly_Bounds(Proportions_File = section_weekly_props, 
                                              Bound_Values_File = section_bound_values)

citywide_weekly_bounds <- Create_Weekly_Bounds(Proportions_File = citywide_weekly_props,
                                               Bound_Values_File = citywide_bound_values)

# Save data tables to the "Data" Folder

# Weekly Section bounds
write.csv(x = section_weekly_bounds, 
          file = "Data/Data_Prep/Weekly_Bounds_Data_Section.csv", 
          row.names = FALSE)

# Weekly Citywide Proportions
write.csv(x = citywide_weekly_bounds, 
          file = "Data/Data_Prep/Weekly_Bounds_Data_Citywide.csv", 
          row.names = FALSE)
