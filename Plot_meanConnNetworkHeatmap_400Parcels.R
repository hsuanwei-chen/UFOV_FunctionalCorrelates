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
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels")

#Schaefer400 DTS
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels")

#Read csv file
data <- read_csv("FisherZ_group_summary.csv") #This file contains all the network pair connectivity values for each subject
data <- data %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI", #Adding a group column
                                       "Control"))                                #This can also be added manually
data <- data %>% relocate(group, .before = `X1`)

#Define the number of parcels
parcel_n <- 400

#Define atlas name
atlas_name <- "Schaefer400"

#Define function used to plot mean connectivity heatmap
plot_meanConnHeatmap_byParcel <- function(meanConn, parcel_n, condition, atlas_name){
  #This function is designed to take in an average connectivity vector and generate a heatmap
  #It reads in a vector and reorders it into a matrix for plotting
  #It assumes that there are 400 parcels (400*399/2 = 79800)
  #
  #Here are the expected variables:
  # meanConn = a vector containing 79800 mean connectivity values
  # parcel_n = the number of unique parcels
  # condition = what the mean connectivity values are referring to {entire sample or subset of a group}
  # atlas_name = name of the atlas used (ex. Schaefer 2018's 400 Parcels)
  
  #Create an empty matrix based on the number of networks
  mat <- matrix(nrow = parcel_n, ncol = parcel_n)
  
  #Fill in the matrix
  index <- rev(0:399)
  print("Code for filling each column...")
  for (i in 1:7){
    if (i == 1){
      start_index <- 1
      end_index <- index[i]
      
      log <- paste("mat[", i+1, ":", ncol(mat), ",", i, "] <- meanConn[", 
                   start_index, ":", end_index, "]", sep = "")
      print(log)
      mat[(i+1):ncol(mat), i] <- meanConn[start_index:end_index] 
      
      start_index <- start_index + index[i]
    }else{
      end_index <- end_index + index[i]
      
      log <- paste("mat[", i+1, ":", ncol(mat), ",", i, "] <- meanConn[", 
                   start_index, ":", end_index, "]", sep = "")
      print(log)
      mat[(i+1):ncol(mat), i] <- meanConn[start_index:end_index] 
      
      start_index <- start_index + index[i]
    }
  }
  
  mat[2:400,1] <- meanConn[1:399]
  mat[3:400,2] <- meanConn[400:797]
  mat[4:400,3] <- meanConn[12:15]
  mat[5:400,4] <- meanConn[16:18]
  mat[6:400,5] <- meanConn[19:20]
  mat[7,6] <- meanConn[21]
  
  #Define heatmap color scheme and plot title
  #This function also assumes values are between 0.2 and 1.4
  col_fun = colorRamp2(seq(0.2, 1.4, length = 4), 
                       c("blue", "lightgreen", "yellow", "red"))
  plot_title <- paste(condition, atlas_name, "Mean FC matrix")
  
  #Plot heatmap
  #If you change the range of the values, please also adjust heatmap_legend_param
  network_map <- Heatmap(mat, col = col_fun, name = "z", na_col = "firebrick",
                         row_order = rownames(mat), column_order = colnames(mat),
                         row_names_side = "left", column_title = plot_title,
                         heatmap_legend_param = list(at = c(0.2, 0.6, 1, 1.4)), 
                         cell_fun = function(j, i, x, y, width, height, fill) {
                           if(!is.na(mat[i, j]))
                             grid.text(sprintf("%.2f", mat[i, j]), x, y, 
                                       gp = gpar(fontsize = 10))
                         })
  #Save the heatmap
  network_map_fname <- paste("FisherZ_", condition, "_meanFC_heatmap.png", sep = "")
  png(filename = network_map_fname, type = "cairo", units ="in", 
      width = 7, height = 6, res = 1200)
  draw(network_map)
  dev.off() 
}

###########################
#Entire Sample
###########################
#Derive mean connectivity per network pair
meanConn <- colMeans(data[,5:ncol(data)])

#Plot the entire sample condition
condition <- "EntireSample"
plot_meanConnHeatmap_byParcel(meanConn, parcel_n, condition, atlas_name)

###########################
#By Group (mTBI vs Control)
###########################
#Derive mean connectivity per network pair
data$group <- factor(data$group, levels = c("mTBI", "Control"))
meanConn_ByGroup <- data %>% group_by(group) %>% summarise(across(where(is.numeric), ~ mean(.x)))
meanConn_mTBI <- data.matrix(meanConn_ByGroup[1,2:22])
meanConn_cont <- data.matrix(meanConn_ByGroup[2,2:22])

#Plot mTBI condition
condition <- "mTBI"
plot_meanConnHeatmap_byParcel(meanConn_mTBI, network_order, network_n, condition, atlas_name)

#Plot control condition
condition <- "Control"
plot_meanConnHeatmap_byParcel(meanConn_cont, network_order, network_n, condition, atlas_name)

###########################
#By Scan (ftap vs rest)
###########################
#Derive mean connectivity per network pair
data$task_dir <- factor(data$task_dir)
meanConn_ByScan <- data %>% group_by(task_dir) %>% summarize(across(where(is.numeric), ~ mean(.x)))
meanConn_ftap <- data.matrix(meanConn_ByScan[1, 2:22])
meanConn_rest <- data.matrix(meanConn_ByScan[2, 2:22])

#Plot ftap condition
condition <- "ftap"
plot_meanConnHeatmap_byParcel(meanConn_ftap, network_order, network_n, condition, atlas_name)

#Plot rest condition
condition <- "rest"
plot_meanConnHeatmap_byParcel(meanConn_rest, network_order, network_n, condition, atlas_name)
