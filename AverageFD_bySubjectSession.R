#Written by Isaac Chen for the UFOV Functional Correlates project
#Clear all the variables in the environment
rm(list=ls())

#Import libraries
library(tidyverse)

#Set up working directory
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/")

#Read csv file
data <- read_csv("MotionSummary_table.csv") #This file contains all the network pair connectivity values for each subject                             #This can also be added manually

#Confirm how many unique subjects there are
unique_subSess <- unique(data[c("subject_id", "sess_date")])

#Concatenate the functional and resting-state scans
avg <- data %>% group_by(subject_id, sess_date) %>% summarise_if(is.numeric, mean)

#Adding a group column
avg <- avg %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI",
                                           "Control"))   
avg <- avg %>% relocate(group, .before = x_mean)

#Save your results
#Isaac forgot to incorporate time point (i.e initial, 3month or 12month earlier, so please add that manually!)
#Adding manually is also helpful because you can decide on what to do with the participants who skipped visits
write.csv(avg, "Averaged_MotionSummary_table.csv", row.names = FALSE)