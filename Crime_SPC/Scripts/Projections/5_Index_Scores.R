### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if using scripts independently of the "Run_All....R" files

source("Functions/Functions.R")

# Read in tables made prior and saved in the "Data" folder

# Bound values
bound_values_section <- read.csv("Data/Data_Prep/Bound_Values_Data_Section.csv", 
                                 header = TRUE,
                                 stringsAsFactors = TRUE)

bound_values_citywide <- read.csv("Data/Data_Prep/Bound_Values_Data_Citywide.csv",
                                  header = TRUE,
                                  stringsAsFactors = TRUE)

# Projection values
projection_values_section <- read.csv("Data/Projections/Yearend_Projections_Section.csv", 
                                      header = TRUE,
                                      stringsAsFactors = TRUE)

projection_values_citywide <- read.csv("Data/Projections/Yearend_Projections_Citywide.csv",
                                  header = TRUE,
                                  stringsAsFactors = TRUE)

# Create Index Scores
index_scores_section <- Create_Index_Scores(Bound_Values_File = bound_values_section,
                                            Yearend_Projections_File = projection_values_section)

index_scores_citywide <- Create_Index_Scores(Bound_Values_File = bound_values_citywide,
                                             Yearend_Projections_File = projection_values_citywide)

# Save data tables to the "Data" Folder

# Section Index Score Table
write.csv(x = index_scores_section, 
          file = "Data/Projections/Index_Scores_Section.csv", 
          row.names = FALSE)

# Citywide Index Score Table
write.csv(x = index_scores_citywide, 
          file = "Data/Projections/Index_Scores_Citywide.csv", 
          row.names = FALSE)
