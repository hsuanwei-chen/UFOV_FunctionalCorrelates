#Written by Isaac Chen for Adrian's Resting-State project
#Clear all the variables in the environment
rm(list=ls())

#Import libraries
library(tidyverse)

#Set up working directory
#Yeo 2011 UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Yeo2011_7Networks")
#Schaefer400 7Networks UFOV
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Read csv file
data <- read_csv("FisherZ_group_summary.csv") #This file contains all the network pair connectivity values for each subject                             
within <- read_csv("FisherZ_WithinNetwork.csv")

#Confirm how many unique subjects there are
unique_subSess <- unique(data[c("subject_id", "sess_date")])
unique_subSess_within <- unique(within[c("subject_id", "sess_date")])

#Concatenate the functional and resting-state scans
avg <- data %>% group_by(subject_id, sess_date) %>% summarise_if(is.numeric, mean)
within_avg <- within %>% group_by(subject_id, sess_date) %>% summarise_if(is.numeric, mean)
  
#Adding a group column
avg <- avg %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI",
                                       "Control"))   
avg <- avg %>% relocate(group, .before = `Vis-SomMot`)

within_avg <- within_avg %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI",
                                     "Control"))   
within_avg <- within_avg %>% relocate(group, .before = `Vis-Vis`)

#Save your results
#Isaac forgot to incorporate time point (i.e initial, 3month or 12month earlier, so please add that manually!)
#Adding manually is also helpful because you can decide on what to do with the participants who skipped visits
write.csv(avg, "Averaged_FisherZ_group_summary.csv", row.names = FALSE)
write.csv(within_avg, "Averaged_WithinNetwork_summary.csv", row.names = FALSE)