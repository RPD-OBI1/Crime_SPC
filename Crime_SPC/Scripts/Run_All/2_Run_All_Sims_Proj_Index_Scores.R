# This script runs all simulations, projections, and index scores for the project

# This path must be set to the location of the "Crime_SPC" folder
setwd("YOURPATH/Crime_SPC/")

source("Scripts/Projections/1_Raw_to_Weekly_Aggregates.R")
source("Scripts/Projections/2_Simulations_for_Remainder_of_Year.R")
source("Scripts/Projections/3_Combine_Current_and_Simulations.R")
source("Scripts/Projections/4_Yearend_Simulation_Summary.R")
source("Scripts/Projections/5_Index_Scores.R")