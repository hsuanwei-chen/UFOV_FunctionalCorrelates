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
#Yeo 2011 UFOV
#("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Yeo2011_7Networks")
#Schaefer400 UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Yeo 2011 DTS
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Yeo2011_7Networks")
#Schaefer400 DTS
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Read csv file
data <- read_csv("FisherZ_group_summary.csv") #This file contains all the network pair connectivity values for each subject
data <- data %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI", #Adding a group column
                                       "Control"))                                #This can also be added manually
data <- data %>% relocate(group, .before = `Vis-SomMot`)

#Define the order of your networks
network_order <-  factor(c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"),
                         levels = c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"))

network_n <- length(network_order)

#Define atlas name
#atlas_name <- "Yeo2011 7Networks"
atlas_name <- "Schaefer400 7Networks"

#Define function used to plot mean connectivity heatmap
plot_meanConnHeatmap <- function(meanConn, network_order, network_n, condition,
                                 atlas_name){
  #This function is designed to take in an average connectivity vector and generate a heatmap
  #It reads in a vector and reorders it into a matrix for plotting
  #It assumes that there are 21 network pairs for a 7 network parcellation (7*6/2 = 21)
  #
  #Here are the expected variables:
  # meanConn = a vector containing 21 mean connectivity values
  # network_order = a character array containing the networks in an user-defined order 
  # network_n = the number of unique networks
  # condition = what the mean connectivity values are referring to {entire sample or subset of a group}
  # atlas_name = name of the atlas used (ex. Yeo2011's 7Network atlas)
  
  #Create an empty matrix based on the number of networks
  mat <- matrix(nrow = network_n, ncol = network_n)
  colnames(mat) <- network_order
  rownames(mat) <- network_order
  
  #Fill in the matrix
  mat[2:7,1] <- meanConn[1:6]; mat[1,2:7] <- meanConn[1:6]
  mat[3:7,2] <- meanConn[7:11]; mat[2,3:7] <- meanConn[7:11]
  mat[4:7,3] <- meanConn[12:15]; mat[3,4:7] <- meanConn[12:15]
  mat[5:7,4] <- meanConn[16:18]; mat[4,5:7] <- meanConn[16:18]
  mat[6:7,5] <- meanConn[19:20]; mat[5,6:7] <- meanConn[19:20]
  mat[7,6] <- meanConn[21]; mat[6,7] <- meanConn[21]
  
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
meanConn <- colMeans(data[,5:25])

#Plot the entire sample condition
condition <- "EntireSample"
plot_meanConnHeatmap(meanConn, network_order, network_n, condition, atlas_name)

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
plot_meanConnHeatmap(meanConn_mTBI, network_order, network_n, condition, atlas_name)

#Plot control condition
condition <- "Control"
plot_meanConnHeatmap(meanConn_cont, network_order, network_n, condition, atlas_name)

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
plot_meanConnHeatmap(meanConn_ftap, network_order, network_n, condition, atlas_name)

#Plot rest condition
condition <- "rest"
plot_meanConnHeatmap(meanConn_rest, network_order, network_n, condition, atlas_name)
