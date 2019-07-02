### This Script calls upon a variety of functions to make calculations from summarized data to create other necessary summary tables

# First set the working directory to the project folder that contains the folders "Data", "Functions" and "Scripts"
# The "Data" folder should contain the raw data used, "Functions" should have all prepared functions, and "Scripts" should contain prepared scripts

# setwd("YOUR_PATH/Crime_SPC/") # This needs to be set if when doing plots

source("Functions/Functions.R")

library(tidyverse)

# RPD Color selections (in the form of a named vector to work with some manual fill arguments later in plots) - modify if desired
color_vals <- c("#F25B4F" = "#F25B4F", # Extreme Red
                "#F69189" = "#F69189", 
                "#FAC8C4" = "#FAC8C4", 
                "#FFFFFF" = "#FFFFFF", # White
                "#CFE9D3" = "#CFE9D3",
                "#9DD3A7" = "#9DD3A7", 
                "#6EBE7C" = "#6EBE7C") # Extreme Green

# Read in tables made prior and saved in the "Data" folder
index_section <- read.csv("Data/Projections/Index_Scores_Section.csv",
                           header = TRUE,
                           stringsAsFactors = FALSE)

index_citywide <- read.csv("Data/Projections/Index_Scores_Citywide.csv",
                           header = TRUE,
                           stringsAsFactors = FALSE)

city.levs <- unique(index_citywide$Section)
sec.levs <- unique(index_section$Section)

# Combine data & assign colors
index <- bind_rows(index_citywide, index_section) %>%
  mutate(Section = factor(Section, levels = c(city.levs, sec.levs)),
         CrimeType = factor(CrimeType)) %>%
  mutate(Section_Crime = paste0(Section, "_", CrimeType), 
         Flag_Med = case_when(Index_Scores_Med >= 75 ~ color_vals[1],
                              Index_Scores_Med >= 50 & Index_Scores_Med < 75 ~ color_vals[2],
                              Index_Scores_Med >= 25 & Index_Scores_Med < 50 ~ color_vals[3],
                              Index_Scores_Med <= -25 & Index_Scores_Med > -50 ~ color_vals[5],
                              Index_Scores_Med <= -50 & Index_Scores_Med > -75 ~ color_vals[6],
                              Index_Scores_Med <= -75 ~ color_vals[7],
                              TRUE ~ color_vals[4]),
         Flag_Avg = case_when(Index_Scores_Avg >= 75 ~ color_vals[1],
                              Index_Scores_Avg >= 50 & Index_Scores_Avg < 75 ~ color_vals[2],
                              Index_Scores_Avg >= 25 & Index_Scores_Avg < 50 ~ color_vals[3],
                              Index_Scores_Avg <= -25 & Index_Scores_Avg > -50 ~ color_vals[5],
                              Index_Scores_Avg <= -50 & Index_Scores_Avg > -75 ~ color_vals[6],
                              Index_Scores_Avg <= -75 ~ color_vals[7],
                              TRUE ~ color_vals[4]),
         Flag_Med_Colors <- setNames(Flag_Med, Section_Crime),
         Flag_Avg_Colors <- setNames(Flag_Avg, Section_Crime)
         
         )



# Create and save plots

B <- Plot_Index_Score(Index_Score_Table = index, 
                      projection_type = "median", 
                      plot_type = "barplot")

ggsave(filename = "Plot_Images/Index_Scores_Plots/Index_Score_Barplot.png",
       plot = B, 
       width = 10, 
       height = 4.5, 
       units = "in")

H <- Plot_Index_Score(Index_Score_Table = index, 
                      projection_type = "median", 
                      plot_type = "heatmap")

ggsave(filename = "Plot_Images/Index_Scores_Plots/Index_Score_Heatmap.png",
       plot = H, 
       width = 10, 
       height = 4.5, 
       units = "in")
