### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")
library(dplyr)

# Read in tables made prior and saved in the "Data" folder

# Current Year Weekly Aggregates
section_current_weekly_aggregates <- read.csv("Data/Projections/Current_Weekly_Section.csv", 
                                              header = TRUE,
                                              stringsAsFactors = TRUE)

citywide_current_weekly_aggregates <- read.csv("Data/Projections/Current_Weekly_Citywide.csv",
                                               header = TRUE,
                                               stringsAsFactors = TRUE)

# Simulations
section_simulations <- read.csv("Data/Projections/Simulations_Section.csv", 
                                header = TRUE,
                                stringsAsFactors = TRUE)

citywide_simulations <- read.csv("Data/Projections/Simulations_Citywide.csv",
                                 header = TRUE,
                                 stringsAsFactors = TRUE)


year_end_simulations_section <- Create_Year_End_Simulations(Current_Year_Weekly_Aggregation_File = section_current_weekly_aggregates, 
                                                            Simulations_File = section_simulations)

year_end_simulations_citywide <- Create_Year_End_Simulations(Current_Year_Weekly_Aggregation_File = citywide_current_weekly_aggregates, 
                                                             Simulations_File = citywide_simulations)

# Save data tables to the "Data" Folder

# Yearend Section Simulated Totals
write.csv(x = year_end_simulations_section, 
          file = "Data/Projections/Yearend_Simulations_Section.csv", 
          row.names = FALSE)

# Yearend Citywide Simulated totals
write.csv(x = year_end_simulations_citywide, 
          file = "Data/Projections/Yearend_Simulations_Citywide.csv", 
          row.names = FALSE)
