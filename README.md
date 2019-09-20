# Crime_SPC
A simple method for monitoring crime levels in your city

This document describes the steps from downloading the "Crime_SPC" folder to a location of your 
choice on your Windows computer to running scripts for monitoring crime levels in your agency. 

The process will go as follows:

- Download and save the "Crime_SPC" folder from github
- Download and Open R for Windows
- Install required packages
- Format crime data specific to project requirements
- Set working directory for project
- Run scripts

Download Crime_SPC folder from github
=====================================

Click the green button "Clone or download" at the top of this screen. From the dropdown, click on "Download ZIP".
This should download a "Crime_SPC-master.zip" folder. Locate this folder in your download location, and open the
folder. In this folder the "Crime_SPC" folder can be found. This folder is required for the project. The user
should save the "Crime_SPC" folder to a location of which the user decides.

Download R for Windows
======================

If you already have R-3.6.0 or greater on your machine and have or can install the tidyverse package 
and the gridExtra package you can skip ahead to an appropriate section.

Go to https://www.r-project.org/ and follow instructions to download R-3.6.0 or 
greater on your Windows computer. For more detailed information on installing R you 
can visit https://cran.r-project.org/bin/windows/base/rw-FAQ.html. After the 
download is complete, open the R application.

Install required packages
=========================

The Crime_SPC requires functions provided by some packages not included in the 
base R download. To make sure that these packages are available for use on your 
machine you will need to download them prior to use. To do so, click in the R Console 
next to the ">" symbol and type (or copy/paste) the following:

	install.packages(c("tidyverse", "gridExtra"))

Press the "Enter" key. If prompted to select a CRAN mirror for session use, select a 
location geographically close to you and click "OK". If correctly downloaded, R 
should notify you by returning:

	package ‘tidyverse’ successfully unpacked and MD5 sums checked
	package ‘gridExtra’ successfully unpacked and MD5 sums checked

R will also notify you the location on your computer where the packages were 
downloaded for your future reference. If R was unable to correctly install please 
visit https://cran.r-project.org/bin/windows/base/rw-FAQ.html#Packages to resolve.

Format crime data specific to project requirements
==================================================

To demonstrate the capabilities of the project, sample data are provided. These files 
can be accessed in the "User_Data" folder within the "Data" folder 
(Crime_SPC/Data/User_Data/) in the project. The files are:

- Historical_Raw_Data.csv
- Current_Year_Raw_Data.csv

To investigate the contents of these sample data .csv files, the user should open the 
file using the "Notepad" applicaton included on Windows machines. "Microsoft Excel" 
or other similar applications may attempt to automatically detect "Date" fields and 
convert them to their software specific formats. Though the underlying data will be 
in the correct format, it may appear to the user that it is something different.

The "Historical_Raw_Data.csv" file contains randomly generated crime incidents for 
complete years 2015 through 2018. The "Current_Year_Raw_Data.csv" file contains crime 
incidents for partial 2019.

Both files are structured in three-column tables containing the following fields:

- Date
- Section
- CrimeType

The sample data (as well as any future user-provided data used for this project) must 
be structured in this way, with column names spelled exactly as demonstrated. "N/A" 
or missing values are not accepted.

The "Date" field contains the date of the recorded incident and must be formatted 
"YYYY-MM-DD". For example, a date of January 18, 2017 would be formatted as 
2017-01-18 in the data table. In order for the scripts to run properly, this detail 
is critical. User preprocessing may be required.

The "Section" field contains any geographical assignment that the incident may have. 
For example, if the agency is broken down by Precincts, then the "Section" field will 
contain those Precinct identifiers. It is important to note that user-provided data 
should be cleaned so that only viable identifiers are used. If the analyst wishes to 
conduct this project with data at the city level (no geographical breakdown) then all 
cells in the "Section" field should be provided as "Citywide". For the sake of the 
sample data, the "Section" field contains six unique identifiers for Sec 1 through 
Sec 6. The functions that create summaries for the projects also have arguments to 
transform "section"-level data to "citywide" data for more advanced users willing to 
make adjustments. To best follow the structure of the sample data, user-provided data 
should be at the "section" level.

The "CrimeType" field contains the most serious Uniform Crime Reporting crime type 
category of the recorded incident. For example, if an incident contained a burglary 
and aggravated assault, that row in the table would only show a unique identifier 
for aggravated assault. This method follows the UCR hierarchy rule found here 
https://ucr.fbi.gov/additional-ucr-publications/ucr_handbook.pdf.
As with the "Section" field, the user-provided data must be cleaned to only included 
viable identifiers whether the UCR categories are used or not.

Though there are four years of data in the "Historical_Raw_Data.csv" file, the
default method for this project uses three years of historical data to calculate
statistically expected bounds (+ /- 2 standard deviations about a weighted average). 
These details can be adjusted by advanced users willing to dive into the code, but 
beginners should expect that no matter the number of years in the 
"Historical_Raw_Data.csv" file, only the most recent three will be used as well as 
the default assigned 2 standard deviations.

If using this method with user-provided data, these sample data files need to be 
replaced within the "User_Data" folder using exactly the same structure and with 
the same exact file names. Any disagreements with these requirements will result
in errors.


Set working directory for project
=================================

In order for R to be able to take the data and properly summarise them, it must
be instructed where the data are saved on the user's machine. Using the setwd()
function a user can define the location of the project folder and alert R to that
address.

First, locate the "Crime_SPC" folder and right-click. Click on 
"Properties" to show the location of the folder. Highlight the address shown at 
"Location:". Within the R Console, click next to the ">" symbol so that the cursor 
is blinking. Using the setwd() function, within the console, paste the location of 
the "Crime_SPC" folder within quotation marks and reverse all "\\" characters 
(for Windows R uses "/" within address locations and will error if not changed). 
At the end of the address type "/Crime_SPC/" to complete the address. Then hit 
the "Enter" key. An example if located on the desktop may look like this:

	setwd("C:/Users/UserName/Desktop/Crime_SPC")

To check to see if R correctly has changed the working directory the user can use:

	getwd()

If correct, R should return the contents of the setwd() function above (as the user 
defined it).

Each time the setwd() function is called, the working directory changes to that 
location. Therefore using this method within the console will work as long as the 
scripts in this project do not overwrite it. To alleviate this, a setwd() function
is placed at the beginning of each script and should be updated with the location of
the "Crime_SPC" folder as described above.

Run scripts
===========

This project is broken down into three main tasks:

1. Processing historical data to create statistically expected ranges
2. Using current data to simulate year-end projections
3. Visualizing current projections against historical ranges

For each task, there are multiple sub-tasks that must be completed in a specific order,
each building off of data summaries created from the prior. After each sub-task 
completes, the script saves .csv files of data summaries and calculations that are 
required for future tasks in the "Data" sub-folders corresponding to the task. Advanced
users can investigate these scripts within the "Scripts" folder, but beginners need 
only focus on the scripts in the "Run_All" folder within the "Scripts" folder. Here the
user will find three files which will run all sub-tasks in the order which they are
required:

- 1_Run_All_Data_Preps.R
- 2_Run_All_Sims_Proj_Index_Scores.R
- 3_Run_All_Plots.R

First, within R, click "File" and "Open script..." from the toolbar. 
Open the "1_Run_All_Data_Preps.R" script. It should open in a new window in editor mode. 
Here, the user should follow the process of finding the location of the "Crime_SPC" 
folder and inserting that address within the setwd() function at the top of the script. 
(Note: the "#" character is a comment character which allows scripts to contain comments 
for future reference which R will not execute. Lines that begin with the "#" symbol will 
not be run, so the user needs to make sure that the line containing the location of the 
"Crime_SPC" folder is not preceded by a "#" symbol and only one setwd() call is to be 
used in the script.)

Once the working directory is updated, the user is then ready to execute task 1.

To do so, highlight all the contents of the script in the editor window either by 
using the mouse or by clicking within the window and hitting "Ctrl + A". If all lines
are highlighted, either click the third button on the toolbar, which on hover reads
"Run line or selection" or hit "Ctrl + Enter". This will execute the four subtasks listed
within the script. If the script was able to successfully run, ten .csv files should
show up in the "Data_Prep" folder within the "Data" folder of the Crime_SPC.
If the files are there, the script can be saved and closed. This script only needs to
run once since it uses the historical data to create the bounds.

Next, open the "2_Run_All_Sims_Proj_Index_Scores.R" file. Again, following the same
process, update the setwd() function and save the script. Highlight all contents in
the editor window and run the selection. This file takes data from the current year
and creates simulations for year-end projections as well as a standardization of
these projections against the bounds stored in the first task. These standardizations
are known as Index Scores and allow the for comparisons across crime types regardless
of the range of total number of crimes that are unique to that "Section" or "CrimeType".
The files created from this process should now appear in the "Projections" folder
within the "Data" folder of Crime_SPC. This task should be run on a weekly basis
allowing for the real-time monitoring of crime. 

Advanced users can use the files produced from task 2 to visualize as they they see fit. 
Beginner users can run the third task which produces plots of all current crime counts
against the bounds created in task 1. To do so open the "3_Run_All_Plots.R" file. Again, 
following the same process, update the setwd() function and save the script. Highlight 
all contents in the editor window and run the selection. This task creates weekly
bounds plots and index scores plots. The weekly bounds plots are a way to track the
rate of the accumulation of crimes as they compare to the ranges shown historically.
These plots are all saved individually as .png files within the "Weekly_Bounds_Plots"
folder in the "Plot_Images" folder in "Crime_SPC". The index scores plots come in
two versions: a barplot and a heatmap. Each is a standardized way to visualise the 
current week's projection against the historical year-end bounds. These .png files are
saved in the "index_Scores_Plot" folder within the "Plot_Images" folder, in the Crime_SPC. 
This task should be run on a weekly basis allowing for the real-time monitoring 
of crime.

The files created in tasks 2 and 3 will overwrite the previous files each time the
script is executed.

Once the tasks have been completed, close R. There is no need to save the workspace.

Contact information
===================

For questions or comments contact kevin.hoyt@cityofrochester.gov
