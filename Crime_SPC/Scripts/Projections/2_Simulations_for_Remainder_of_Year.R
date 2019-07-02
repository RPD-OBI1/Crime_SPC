### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")

# Read in tables made prior and saved in the "Data" folder

# Current Year Weekly Aggregates
section_current_weekly_aggregates <- read.csv("Data/Projections/Current_Weekly_Section.csv", 
                                              header = TRUE,
                                              stringsAsFactors = TRUE)

citywide_current_weekly_aggregates <- read.csv("Data/Projections/Current_Weekly_Citywide.csv",
                                               header = TRUE,
                                               stringsAsFactors = TRUE)


# Weekly Props and Averages
section_weekly_props <- read.csv("Data/Data_Prep/Weekly_Proportions_Data_Section.csv", 
                                 header = TRUE,
                                 stringsAsFactors = TRUE)

citywide_weekly_props <- read.csv("Data/Data_Prep/Weekly_Proportions_Data_Citywide.csv", 
                                  header = TRUE,
                                  stringsAsFactors = TRUE)


# Run Simulations with average method (median is only recommended in situations where many years of data are available)

Section_Simulations <- Create_Simulations(Current_Year_Weekly_Aggregation_File = section_current_weekly_aggregates, 
                                          Weekly_Props_and_Avgs_File = section_weekly_props,
                                          number_of_simulations = 1000,
                                          method = "average")

Citywide_Simulations <- Create_Simulations(Current_Year_Weekly_Aggregation_File = citywide_current_weekly_aggregates, 
                                           Weekly_Props_and_Avgs_File = citywide_weekly_props,
                                           number_of_simulations = 1000,
                                           method = "average")

# Save data tables to the "Data" Folder

# Weekly Section bounds
write.csv(x = Section_Simulations, 
          file = "Data/Projections/Simulations_Section.csv", 
          row.names = FALSE)

# Weekly Citywide Proportions
write.csv(x = Citywide_Simulations, 
          file = "Data/Projections/Simulations_Citywide.csv", 
          row.names = FALSE)
