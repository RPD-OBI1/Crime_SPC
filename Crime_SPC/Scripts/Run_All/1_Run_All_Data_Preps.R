# This script runs all data preparation components of the project

# This path must be set to the location of the "Crime_SPC" folder
setwd("YOUR_PATH/Crime_SPC/") 

source("Scripts/Data_Prep/1_Raw_to_Aggregates.R")
source("Scripts/Data_Prep/2_Yearly_Aggregates_to_Yearly_Bounds.R")
source("Scripts/Data_Prep/3_Weekly_Aggregates_to_Props_and_Avgs.R")
source("Scripts/Data_Prep/4_Props_to_Weekly_Bounds.R")