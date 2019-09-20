### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if when doing plots

source("Functions/Functions.R")
library(tidyverse)

# Read in tables made prior and saved in the "Data" folder
weekly_bounds_section <- read.csv("Data/Data_Prep/Weekly_Bounds_Data_Section.csv",
                                  header = TRUE,
                                  stringsAsFactors = TRUE)

weekly_bounds_citywide <- read.csv("Data/Data_Prep/Weekly_Bounds_Data_Citywide.csv",
                                   header = TRUE,
                                   stringsAsFactors = TRUE)

weekly_current_section <- read.csv("Data/Projections/Current_Weekly_Section.csv",
                                   header = TRUE,
                                   stringsAsFactors = TRUE)

weekly_current_citywide <- read.csv("Data/Projections/Current_Weekly_Citywide.csv",
                                   header = TRUE,
                                   stringsAsFactors = TRUE)

yearend_simulations_section <- read.csv("Data/Projections/Yearend_Simulations_Section.csv",
                                         header = TRUE,
                                         stringsAsFactors = TRUE)

yearend_simulations_citywide <- read.csv("Data/Projections/Yearend_Simulations_Citywide.csv",
                                         header = TRUE,
                                         stringsAsFactors = TRUE)

yearend_projection_section <- read.csv("Data/Projections/Yearend_Projections_Section.csv",
                                       header = TRUE,
                                       stringsAsFactors = TRUE)

yearend_projection_citywide <- read.csv("Data/Projections/Yearend_Projections_Citywide.csv",
                                       header = TRUE,
                                       stringsAsFactors = TRUE)


### Combine Data
weekly_bounds <- bind_rows(weekly_bounds_citywide, weekly_bounds_section) %>%
  mutate(SevenDaysGroup = as.numeric(SevenDaysGroup))

weekly_currents <- bind_rows(weekly_current_citywide, weekly_current_section) %>%
  mutate(SevenDaysGroup = as.numeric(SevenDaysGroup),
         Point_Color = case_when(Cumulative_Total > weekly_bounds$Weekly_Upper_Bound ~ "red",
                                 Cumulative_Total < weekly_bounds$Weekly_Lower_Bound ~ "green",
                                 TRUE ~ "black"))

yearend_simulations <- bind_rows(yearend_simulations_citywide, yearend_simulations_section)

yearend_projections <- bind_rows(yearend_projection_citywide, yearend_projection_section)

###################################################################
#  Make plots for each geographic area and crime type
###################################################################

for(i in unique(weekly_bounds$Section)){
  
  for(j in unique(weekly_bounds$CrimeType)){
    
    section <- i
    crimetype <- j
    
    # Subset data to only include selections
    
    bounds <- weekly_bounds %>%
      filter(Section == section & CrimeType == crimetype)
    
    currs <- weekly_currents %>%
      filter(Section == section & CrimeType == crimetype)
    
    sims <-  yearend_simulations %>%
      filter(Section == section & CrimeType == crimetype) %>%
      group_by(Simulated_Yearend_Total) %>%
      summarise(Totals = n()) %>%
      mutate(SevenDaysGroup = 52)
    
    projs <- yearend_projections %>%
      filter(Section == section & CrimeType == crimetype) %>%
      mutate(SevenDaysGroup = 52)
    
    # Plot the data
    P <-  Plot_Current_Year(Bounds_Table = bounds,
                            Current_Table = currs,
                            Yearend_Simulations_Table = sims,
                            Projections_Table = projs, 
                            Section = section, 
                            CrimeType = crimetype, 
                            projection_type = "median")
    
    ggsave(filename = paste0("Plot_Images/Weekly_Bounds_Plots/", section, "_", crimetype, ".png"),
           plot = P, 
           width = 6, 
           height = 3.5, 
           units = "in")
    
  }
  
}
