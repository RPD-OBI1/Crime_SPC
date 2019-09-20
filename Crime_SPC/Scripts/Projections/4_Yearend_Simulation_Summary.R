### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")
library(dplyr)

# Read in tables made prior and saved in the "Data" folder

# Current yearend simulations
section_yearend_simulations <- read.csv("Data/Projections/Yearend_Simulations_Section.csv", 
                                        header = TRUE,
                                        stringsAsFactors = TRUE)

citywide_yearend_simulations <- read.csv("Data/Projections/Yearend_Simulations_Citywide.csv",
                                          header = TRUE,
                                          stringsAsFactors = TRUE)

# Create summary tables
section_simulation_summary <- Create_Yearend_Projections(Yearend_Simulations_File = section_yearend_simulations)

citywide_simulation_summary <- Create_Yearend_Projections(Yearend_Simulations_File = citywide_yearend_simulations)


# Save data tables to the "Data" Folder

# Yearend Section Simulation Summary
write.csv(x = section_simulation_summary, 
          file = "Data/Projections/Yearend_Projections_Section.csv", 
          row.names = FALSE)

# Yearend Citywide Simulation Summary
write.csv(x = citywide_simulation_summary, 
          file = "Data/Projections/Yearend_Projections_Citywide.csv", 
          row.names = FALSE)
