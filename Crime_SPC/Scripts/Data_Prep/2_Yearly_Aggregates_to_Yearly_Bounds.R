
### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")
library(dplyr)

# Weighted Averages Table

# Read in Yearly summary tables created from Data_Prep.R file saved in the "Data" Folder
yearly_section_summary_table <- read.csv(file = "Data/Data_Prep/Aggregate_Data_Yearly_Section.csv",
                                         header = TRUE,
                                         stringsAsFactors = TRUE)

yearly_citywide_summary_table <- read.csv(file = "Data/Data_Prep/Aggregate_Data_Yearly_Citywide.csv",
                                          header = TRUE,
                                          stringsAsFactors = TRUE)

### A decision needs to be made on how to calculate the center value for the bounds.
### This function takes an argument for the number of full years to include (most recent)
### and also the weighting scheme for each of those years in order from weighting for most recent year to least recent recent year.
### If no weighting is required, the vector of weights should all be 1s.
### By default, 3 years are used with a weighting of 3, 2, 1.
### For the upper and lower limits the number of standard devations (sd) from the weighted average must be provided. The default is set to 2.

section_bound_values <- Create_Bound_Values(data_input = yearly_section_summary_table,
                                            number_of_years = 3,
                                            weights = c(3, 2, 1),
                                            sd = 2)

citywide_bound_values <- Create_Bound_Values(data_input = yearly_citywide_summary_table,
                                             number_of_years = 3,
                                             weights = c(3, 2, 1),
                                             sd = 2)
# Save data tables to the "Data" Folder

# Section Bound Values
write.csv(x = section_bound_values, 
          file = "Data/Data_Prep/Bound_Values_Data_Section.csv", 
          row.names = FALSE)

# Weekly Citywide Level
write.csv(x = citywide_bound_values, 
          file = "Data/Data_Prep/Bound_Values_Data_Citywide.csv", 
          row.names = FALSE)
