#Written by Isaac Chen for Adrian's Resting-State project
#Clear all the variables in the environment
rm(list=ls())
#Print warnings as they come up for troubleshooting purposes
options(warn=1)

#Import libraries
library(tidyverse)
library(ComplexHeatmap)
library(circlize)

###########################
#User defined variables
###########################
#Set working directory
#Schaefer400 UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels")

#Schaefer400 DTS
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels")

#Read csv file
data <- read_csv("FisherZ_group_summary.csv") #This file contains all the network pair connectivity values for each subject
data <- data %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI", #Adding a group column
                                       "Control"))                                #This can also be added manually
data <- data %>% relocate(group, .before = `X1`)

matching = read_csv("T:/Stacy/Scans/Scripts/UFOV_FunctionalCorrelates/Schaefer2018_400Parcels_Matching.csv")

#Define the network order and number of parcels
network_order <-  factor(c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"),
                         levels = c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"))
parcel_n <- 400

#Define atlas name
atlas_name <- "Schaefer400"

#Call on the function we will use to create our plots
source("T:/Stacy/Scans/Scripts/UFOV_FunctionalCorrelates/meanConnNetworkHeatmap_byParcel.R")

###########################
#Entire Sample
###########################
#Derive mean connectivity per network pair
meanConn <- colMeans(data[,5:ncol(data)])

#Plot the entire sample condition
condition <- "EntireSample"
meanConnHeatmap_byParcel(meanConn, network_order, parcel_n, condition, atlas_name)

###########################
#By Group (mTBI vs Control)
###########################
#Derive mean connectivity per network pair
data$group <- factor(data$group, levels = c("mTBI", "Control"))
meanConn_byGroup <- data %>% group_by(group) %>% summarise(across(where(is.numeric), ~ mean(.x)))
meanConn_mTBI <- data.matrix(meanConn_byGroup[1,2:ncol(meanConn_byGroup)])
meanConn_cont <- data.matrix(meanConn_byGroup[2,2:ncol(meanConn_byGroup)])

#Plot mTBI condition
condition <- "mTBI"
meanConnHeatmap_byParcel(meanConn_mTBI, network_order, parcel_n, condition, atlas_name)

#Plot control condition
condition <- "Control"
meanConnHeatmap_byParcel(meanConn_cont, network_order, parcel_n, condition, atlas_name)

###########################
#By Scan (ftap vs rest)
###########################
#Derive mean connectivity per network pair
data$task_dir <- factor(data$task_dir)
meanConn_byScan <- data %>% group_by(task_dir) %>% summarize(across(where(is.numeric), ~ mean(.x)))
meanConn_ftap <- data.matrix(meanConn_byScan[1, 2:ncol(meanConn_byScan)])
meanConn_rest <- data.matrix(meanConn_byScan[2, 2:ncol(meanConn_byScan)])

#Plot ftap condition
condition <- "ftap"
meanConnHeatmap_byParcel(meanConn_ftap, network_order, parcel_n, condition, atlas_name)

#Plot rest condition
condition <- "rest"
meanConnHeatmap_byParcel(meanConn_rest, network_order, parcel_n, condition, atlas_name)
