
### The following function will input this dataframe and aggregate to the week level
Create_Weekly_Aggregate <- function(data_input = NULL, city_wide = FALSE){
  
  library(dplyr)
  
  sevenDayGroupTable<- data.frame(DOY= 1:366, 
                                  Group= c(rep(1:51, each= 7), rep(52, each= 9)))
  
  
  if(city_wide == TRUE){
    
    data_input <- data_input %>%
      mutate(Section = "Citywide")
    
  }
  
  
  df <- data_input %>%
    mutate(Date = as.Date(Date)) %>%
    mutate(DOY = as.numeric(format(Date, "%j"))) %>%
    mutate(SevenDaysGroup = sevenDayGroupTable$Group[match(DOY, sevenDayGroupTable$DOY)],
           Year = format(Date, "%Y")) %>%
    mutate(SevenDaysGroup = factor(SevenDaysGroup, levels = 0:52))
  
  max.date <- as.numeric(format(max(df$Date), "%j"))

  weekly_aggregate <- df %>%
    group_by(Year, Section, CrimeType, SevenDaysGroup, .drop = F) %>%
    summarise(Total = n()) %>%
    arrange(Year, Section, CrimeType, SevenDaysGroup) %>%
    group_by(Year, Section, CrimeType, .drop = F) %>%
    mutate(Cumulative_Total = cumsum(Total)) %>%
    ungroup()
  
  # Test to see if the current year is the year being used in which case NAs are put in for weeks that haven't occurred yet
  curr.year <- format(Sys.Date(), "%Y")
  data.years <- unique(weekly_aggregate$Year)
  
  is_current_year <- ifelse(identical(curr.year, data.years), TRUE, FALSE)
  
  if(is_current_year == TRUE){
    
    current.week <- sevenDayGroupTable %>%
      filter(DOY == max.date) %>%
      select(Group) %>%
      slice(1) %>%
      as.numeric()
    
    # Need a delay for reports to get into the system, so we will capture only last full week
    weekly_aggregate <- weekly_aggregate %>%
      mutate(Total = replace(Total, SevenDaysGroup %in% current.week:52, values = NA),
             Cumulative_Total = replace(Cumulative_Total, SevenDaysGroup %in% current.week:52, values = NA))
      
  }
  
  return(weekly_aggregate)
  
}

### The following function will input this dataframe and aggregate to the year level
Create_Yearly_Aggregate <- function(data_input = NULL, city_wide = FALSE){
  
  library(dplyr)
  
  sevenDayGroupTable<- data.frame(DOY= 1:366, 
                                  Group= c(rep(1:51, each= 7), rep(52, each= 9)))
  
  if(city_wide == TRUE){
    
    data_input <- data_input %>%
      mutate(Section = "Citywide")
    
  } else {
    
    data_input <- data_input
  }
  
  df <- data_input %>%
    mutate(Date = as.Date(Date)) %>%
    mutate(Section = factor(trimws(Section)),
           CrimeType = factor(trimws(CrimeType)),
           Year = format(Date, "%Y"))
  
  yearly_aggregate <- df %>%
    group_by(Year, Section, CrimeType, .drop = F) %>%
    summarise(Total = n()) %>%
    arrange(Year, Section) %>%
    ungroup()
  
  return(yearly_aggregate)
  
}

### The following function takes the yearly summary table and creates a new table with weighted average, and upper and lower action limit
Create_Bound_Values <- function(data_input = NULL, 
                                     city_wide = FALSE, 
                                     number_of_years = 3, 
                                     weights = c(3, 2, 1), 
                                     sd = 2){
  
  library(dplyr)
  
  if(city_wide == TRUE){
    
    data_input <- data_input %>%
      mutate(Section = "Citywide")
    
  } else {
    
    data_input <- data_input
  }
  
  last.year <- max(as.numeric(data_input$Year))
  year.seq <- c((last.year - (number_of_years - 1)):last.year)
  
  if(length(weights) != number_of_years) stop("The number of weights provided does not equal the number of years selected.")
  if(all(year.seq %in% unique(data_input$Year)) ==  FALSE) stop("Some of the years selected do no exist in the data provided.")
  
  df <- data_input %>%
    mutate(Year = as.numeric(Year)) %>%
    filter(Year %in% year.seq) %>%
    arrange(Section, CrimeType, -Year) 
  
  
  bound_values <- df %>%
    mutate(Weight = rep(x = weights, times = n() / length(weights))) %>%
    mutate(Weighted_Val = Total * Weight) %>%
    group_by(Section, CrimeType, .drop = F) %>%
    summarise(Weighted_Average = sum(Weighted_Val) / sum(weights)) %>%
    ungroup() %>%
    mutate(Upper_Limit = Weighted_Average + (sd * sqrt(Weighted_Average)),
           Lower_Limit = ifelse(Weighted_Average - (sd * sqrt(Weighted_Average)) < 0,
                                0,
                                Weighted_Average - (sd * sqrt(Weighted_Average)))) %>%
    ungroup()
  
  return(bound_values)
  
}


### The following function takes weekly aggregates and outputs a proportion table based on week.
# The more years of data, the less noise in the data. The default is set to three years, RPD used 7
Create_Weekly_Proportions <- function(data_input = NULL, number_of_years = 3){
  
  library(dplyr)
  
  last.year <- max(as.numeric(data_input$Year))
  year.seq <- c((last.year - (number_of_years - 1)):last.year)
  
  df <- data_input %>%
    filter(Year %in% year.seq) %>%
    group_by(Section, CrimeType, SevenDaysGroup, .drop = F) %>%
    summarise(Week_Totals_All_Years = sum(Total),
              Week_Average = mean(Total),
              Week_Median = median(Total)) %>%
    mutate(Proportion = Week_Totals_All_Years / sum(Week_Totals_All_Years)) %>%
    mutate(Cumulative_Prop = cumsum(Proportion)) %>%
    ungroup()
  
  return(df)
  
}


### The following function takes Year-end bound values and applies the weekly proportions to determine the weekly bounds
Create_Weekly_Bounds <- function(Proportions_File = NULL, Bound_Values_File = NULL){
  
  library(dplyr)
  
  df <- Proportions_File %>% left_join(Bound_Values_File, by = c("Section", "CrimeType"))
  
  weekly_bounds <- df %>%
    mutate(Weekly_Upper_Bound = Cumulative_Prop * Upper_Limit,
           Weekly_Center_Line = Cumulative_Prop * Weighted_Average,
           Weekly_Lower_Bound = Cumulative_Prop * Lower_Limit)
  
  return(weekly_bounds)
  
}

### The following function takes current cumulative values of crime and the average weekly values from previous calculations
### to simulate the possible expected values for the remainder of the year. The output will be a table containing all future simulations
Create_Simulations <- function(Current_Year_Weekly_Aggregation_File = NULL, 
                               Weekly_Props_and_Avgs_File = NULL, 
                               number_of_simulations = 1000,
                               method = c("average", "median")){
  
  library(dplyr)
  
  method <- match.arg(method, choices = c("average", "median"))
  
  remainder_of_year <- Current_Year_Weekly_Aggregation_File %>%
    filter(is.na(Cumulative_Total)) %>%
    left_join(Weekly_Props_and_Avgs_File, by = c("Section", "CrimeType", "SevenDaysGroup")) %>%
    select(-c(Year, Total, Cumulative_Total, Proportion, Cumulative_Prop))
  
  
# Input random samples from the Poisson distribution a.k.a simulate possible values from Poisson process  
  
  if(method == "median"){
    
    sims <- replicate(n = number_of_simulations, 
                         exp = rpois(n = nrow(remainder_of_year), 
                                     lambda = remainder_of_year$Week_Median))
    
  }else{
 
    sims <- replicate(n = number_of_simulations, 
                      exp = rpois(n = nrow(remainder_of_year), 
                                  lambda = remainder_of_year$Week_Average))
    
  }

  
# Convert to a dataframe  
    sims_df <- as.data.frame(sims)
    names(sims_df) <- paste0("sim", 1:number_of_simulations)
    
# Combine the remainder_of_year file and the simulations
  df <- bind_cols(remainder_of_year, sims_df) %>%
    select(-c(Week_Totals_All_Years, Week_Average, Week_Median))
  
  return(df)
    
}


### The following function takes the simulations data and creates year-end totals with the two.
Create_Year_End_Simulations <- function(Current_Year_Weekly_Aggregation_File = NULL,
                                        Simulations_File = NULL){

  library(dplyr)
  library(tidyr)
  
  data.thru <- Current_Year_Weekly_Aggregation_File %>%
    filter(!is.na(Cumulative_Total)) %>%
    select(SevenDaysGroup) %>%
    max()
  
  current_totals <- Current_Year_Weekly_Aggregation_File %>%
    filter(SevenDaysGroup == data.thru) %>%
    select(-c(Year, SevenDaysGroup, Total))
  
  cumulative_remainders <- Simulations_File %>%
    select(-SevenDaysGroup) %>%
    gather(key = Simulation, value = Total, -c(Section, CrimeType)) %>%
    group_by(Section, CrimeType, Simulation, .drop = F) %>%
    summarise(Cumulative_Remainders = sum(Total))
  
  simulations_join <- cumulative_remainders %>%
    left_join(current_totals, by = c("Section", "CrimeType")) %>%
    mutate(Simulated_Yearend_Total = Cumulative_Remainders + Cumulative_Total)
  
  return(simulations_join)
  
}

# This function takes the year-end simulations and summarizes with both the "average" and "median".
# Median is preferred use because it is capable of better summarizing skewed distributions from small weekly averages
Create_Yearend_Projections <- function(Yearend_Simulations_File = NULL){
  
  library(dplyr)
  
    df <- Yearend_Simulations_File %>%
      group_by(Section, CrimeType, .drop = F) %>%
      summarise(Projected_Total_Med = ceiling(median(Simulated_Yearend_Total)), # use ceiling to create an integer, rounded up to be safe
                Projected_Total_Avg = ceiling(mean(Simulated_Yearend_Total)))
  
 return(df)
  
}


# This function takes the yearend projection and rescales the bounds to -50 to 50
Create_Index_Scores <- function(Bound_Values_File = NULL,
                                Yearend_Projections_File = NULL){
  
  library(dplyr)
  
  # "_Med" = index score created using the median projection
  # "_Avg" = index score created using the average projection
  
  bound_projection_join <- Bound_Values_File %>%
    left_join(Yearend_Projections_File, by = c("Section", "CrimeType")) %>%
    mutate(Index_Scores_M_temp = round((((Projected_Total_Med - Lower_Limit) / (Upper_Limit - Lower_Limit)) - 0.5) * 100),
           Index_Scores_A_temp = round((((Projected_Total_Avg - Lower_Limit) / (Upper_Limit - Lower_Limit)) - 0.5) * 100))
  
  df <- bound_projection_join %>%
    mutate(Index_Scores_Med = case_when(Index_Scores_M_temp > 100 ~ 100,
                                        Index_Scores_M_temp < -100 ~ -100,
                                        TRUE ~ Index_Scores_M_temp),
           Index_Scores_Avg = case_when(Index_Scores_A_temp > 100 ~ 100,
                                        Index_Scores_A_temp < -100 ~ -100,
                                        TRUE ~ Index_Scores_A_temp)) %>%
    select(Section, CrimeType, Upper_Limit, Lower_Limit, Projected_Total_Med, Projected_Total_Avg, Index_Scores_Med, Index_Scores_Avg)
  
  return(df)
  
}

# This function plots the cumulative weekly expected range as well as the current cumulative weekly totals and year-end projections

Plot_Current_Year <- function(Bounds_Table = NULL,
                              Current_Table = NULL,
                              Yearend_Simulations_Table = NULL,
                              Projections_Table = NULL,
                              Section = NULL, 
                              CrimeType = NULL, 
                              projection_type = c("average", "median")){
  
  library(tidyverse)
  
  projection_type <- match.arg(projection_type, choices = c("average", "median"))
  
  section <- Section
  crimetype <- CrimeType
  
  if(projection_type == "median"){
    
    g <- ggplot() +
      geom_ribbon(data = bounds, aes(x = SevenDaysGroup, ymin = Weekly_Lower_Bound, ymax = Weekly_Upper_Bound), 
                  fill = "steelblue", color = "grey", alpha = 0.3) +
      geom_line(data = currs, aes(x = SevenDaysGroup, y = Cumulative_Total), color = "grey") +
      geom_point(data = currs, aes(x = SevenDaysGroup, y = Cumulative_Total), color = currs$Point_Color) +
      geom_point(data = sims, aes(x = SevenDaysGroup, y = Simulated_Yearend_Total, size = Totals), alpha = 0.05) +
      geom_point(data = projs, aes(x = SevenDaysGroup, y = Projected_Total_Med), size = 4, color = "blue") +
      labs(x = "Week", y = "Count") +
      ggtitle(paste0("Year-end Projections for ", section, " ", crimetype)) +
      theme_bw() +
      theme(legend.position = "none")
    
  } else {
    
    g <- ggplot() +
      geom_ribbon(data = bounds, aes(x = SevenDaysGroup, ymin = Weekly_Lower_Bound, ymax = Weekly_Upper_Bound), 
                  fill = "steelblue", color = "grey", alpha = 0.3) +
      geom_line(data = currs, aes(x = SevenDaysGroup, y = Cumulative_Total), color = "grey") +
      geom_point(data = currs, aes(x = SevenDaysGroup, y = Cumulative_Total), color = currs$Point_Color) +
      geom_point(data = sims, aes(x = SevenDaysGroup, y = Simulated_Yearend_Total, size = Totals), alpha = 0.05) +
      geom_point(data = projs, aes(x = SevenDaysGroup, y = Projected_Total_Avg), size = 4, color = "blue") +
      labs(x = "Week", y = "Count") +
      ggtitle(paste0("Year-end Projections for ", section, " ", crimetype)) +
      theme_bw() +
      theme(legend.position = "none")
    
  }
  
  return(g)
  
}


Plot_Index_Score <- function(Index_Score_Table = NULL,
                             projection_type = c("average", "median"),
                             plot_type = c("barplot", "heatmap")){
  
  require(tidyverse)
  
  projection_type <- match.arg(projection_type, choices = c("average", "median"))
  plot_type <- match.arg(plot_type, choices = c("barplot", "heatmap"))
  
  # The colors RPD has decided to use for the index plots
  color_vals <- c("#F25B4F" = "#F25B4F", # Extreme Red
                  "#F69189" = "#F69189", 
                  "#FAC8C4" = "#FAC8C4", 
                  "#FFFFFF" = "#FFFFFF", # White
                  "#CFE9D3" = "#CFE9D3",
                  "#9DD3A7" = "#9DD3A7", 
                  "#6EBE7C" = "#6EBE7C") # Extreme Green
  
  
  if(projection_type == "median" & plot_type  == "barplot"){
    
    g <- ggplot(Index_Score_Table) +
      geom_hline(yintercept = c(-100, -75, -25, 25, 75, 100), linetype = "dashed") +
      geom_hline(yintercept = c(-50, 50), linetype = "dashed", size = 1.5) +
      geom_bar(aes(x = Section, y = Index_Scores_Med, fill = Section_Crime), stat = "identity", colour = "black") +
      scale_fill_manual(values = Index_Score_Table$Flag_Med_Colors) +
      facet_wrap(CrimeType ~ ., nrow = 1) +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
            legend.position = "none") +
      ggtitle("Index Scores")
    
  }
  
  
  if(projection_type == "average" & plot_type  == "barplot"){
    
    g <- ggplot(Index_Score_Table) +
      geom_hline(yintercept = c(-100, -75, -25, 25, 75, 100), linetype = "dashed") +
      geom_hline(yintercept = c(-50, 50), linetype = "dashed", size = 1.5) +
      geom_bar(aes(x = Section, y = Index_Scores_Avg, fill = Section_Crime), stat = "identity", colour = "black") +
      scale_fill_manual(values = unname(Index_Score_Table$Flag_Avg)) +
      facet_wrap(CrimeType ~ ., nrow = 1) +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
            legend.position = "none") +
      ggtitle("Index Scores")
    
  }
  
  
  legendPlot <- ggplot() +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = -100, ymax = -75), fill = color_vals[7]) +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = -75, ymax = -50), fill = color_vals[6]) +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = -50, ymax = -25), fill = color_vals[5]) +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = -25, ymax = 25), fill = color_vals[4]) +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = 50, ymax = 25), fill = color_vals[3]) +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = 75, ymax = 50), fill = color_vals[2]) +
    geom_rect(aes(xmin = 0, xmax = 10, ymin = 100, ymax = 75), fill = color_vals[1]) +
    geom_hline(aes(yintercept = c(-50, 50)), size = 1, linetype = "dashed") +
    scale_y_continuous(breaks = c(-100, -75, -50, -25, 0, 25, 50, 75, 100), labels = c(-100, -75, -50, -25, 0, 25, 50, 75, 100)) +
    theme_classic() +
    theme(axis.line = element_blank(), 
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank()) +
    geom_text(aes(x = c(5, 5, 5, 5, 5, 5, 5), y = c(-87.5, -62.5, -37.5, 0, 37.5, 62.5, 87.5), 
                  label = c("Extremely Low", "Low", "Slightly Low", "Normal", "Slightly High", "High", "Extremely High")),
              size = 3) +
    labs(title = "Index Score")
  
  
  if(projection_type == "median" & plot_type  == "heatmap"){
    
    tileplot <- ggplot(data = Index_Score_Table, aes(x = Section, 
                                                     y = CrimeType,
                                                     fill = Flag_Med)) +
      geom_tile(show.legend = FALSE) +
      geom_text(aes(label = Index_Scores_Med)) +
      theme_bw() +
      scale_x_discrete(position = "top") +
      scale_fill_manual(breaks = color_vals,
                        values = color_vals) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_text(angle = 0, vjust = 1))
    
    g <- gridExtra::grid.arrange(grobs = list(tileplot, legendPlot), nrow = 1, layout_matrix = rbind(c(1, 1, 1, 1, 2)))
    
  }
  
  if(projection_type == "average" & plot_type  == "heatmap"){
    
    tileplot <- ggplot(data = Index_Score_Table, aes(x = Section, 
                                                     y = CrimeType,
                                                     fill = Flag_Avg)) +
    geom_tile(show.legend = FALSE) +
      geom_text(aes(label = Index_Scores_Avg)) +
    theme_bw() +
      scale_x_discrete(position = "top") +
      scale_fill_manual(breaks = color_vals,
                        values = color_vals) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_text(angle = 0, vjust = 1))
    
    g <- gridExtra::grid.arrange(grobs = list(tileplot, legendPlot), nrow = 1, layout_matrix = rbind(c(1, 1, 1, 1, 2)))
    
  }
  
  return(g)
  
}
