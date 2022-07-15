#Written by Isaac Chen for Adrian's Resting-State project
#Clear all the variables in the environment
rm(list=ls())

#Import libraries
library(tidyverse)

#Set up working directory
#Yeo 2011 UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Yeo2011_7Networks")
#Schaefer400 7Networks UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Yeo 2011 DTS
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Yeo2011_7Networks")
#Schaefer400 7Networks DTS
#("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Set working directory
#Schaefer400 UFOV
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels")

#Schaefer400 DTS
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels")

#Read csv file
data <- read_csv("FisherZ_group_summary.csv") #This file contains all the network pair connectivity values for each subject                             #This can also be added manually

#Confirm how many unique subjects there are
unique_subSess <- unique(data[c("subject_id", "sess_date")])

#Concatenate the functional and resting-state scans
concat <- data %>% group_by(subject_id, sess_date) %>% summarise_if(is.numeric, mean)

#Adding a group column
concat <- concat %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI",
                                           "Control"))   
concat <- concat %>% relocate(group, .before = X1)

#Save your results
#Isaac forgot to incorporate time point (i.e initial, 3month or 12month earlier, so please add that manually!)
#Adding manually is also helpful because you can decide on what to do with the participants who skipped visits
write.csv(concat, "Concat_FisherZ_group_summary.csv", row.names = FALSE)