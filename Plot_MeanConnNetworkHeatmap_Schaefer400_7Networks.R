rm(list=ls())

#Import libraries
library(tidyverse)
library(ComplexHeatmap)
library(circlize)

#Set relevant directories
#Schaefer400 UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Schaefer400 DTS
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks")

#Read csv file
data <- read_csv("FisherZ_group_summary.csv")
data <- data %>% mutate(group = ifelse(startsWith(subject_id, "sub-BR1"), "mTBI", 
                                       "Control"))
data <- data %>% relocate(group, .before = `Vis-SomMot`)

network_order <-  factor(c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"),
                         levels = c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"))

#Calculate mean connectivity per network pair
mean_conn <- colMeans(data[,5:25])
mean_conn_ByGroup <- data %>% group_by(group) %>% summarise(across(where(is.numeric), ~ mean(.x)))
mean_conn_mTBI <- data.matrix(mean_conn_ByGroup[2,2:22])
mean_conn_cont <- data.matrix(mean_conn_ByGroup[1,2:22])

#########################
#Entire Sample
#########################
#Construct an empty matrix
mat <- matrix(nrow = 7, ncol = 7)
colnames(mat) <- network_order
rownames(mat) <- network_order

#Fill in the matrix
mat[2:7,1] <- mean_conn[1:6]; mat[1,2:7] <- mean_conn[1:6]
mat[3:7,2] <- mean_conn[7:11]; mat[2,3:7] <- mean_conn[7:11]
mat[4:7,3] <- mean_conn[12:15]; mat[3,4:7] <- mean_conn[12:15]
mat[5:7,4] <- mean_conn[16:18]; mat[4,5:7] <- mean_conn[16:18]
mat[6:7,5] <- mean_conn[19:20]; mat[5,6:7] <- mean_conn[19:20]
mat[7,6] <- mean_conn[21]; mat[6,7] <- mean_conn[21]

#Plot heatmap
col_fun = colorRamp2(seq(0.2, 1.4, length = 4), 
                     c("blue", "lightgreen", "yellow", "red"))
plot_title <- paste("Entire Sample Schaefer400 7Networks Mean FC matrix")

network_map <- Heatmap(mat, col = col_fun, name = "z", na_col = "firebrick",
                       row_order = rownames(mat), column_order = colnames(mat),
                       row_names_side = "left", column_title = plot_title,
                       heatmap_legend_param = list(at = c(0.2, 0.6, 1, 1.4)), 
                       cell_fun = function(j, i, x, y, width, height, fill) {
                         if(!is.na(mat[i, j]))
                           grid.text(sprintf("%.2f", mat[i, j]), x, y, gp = gpar(fontsize = 10))
                       })

png(filename = "FisherZ_EntireSample_MeanFC_heatmap.png", type = "cairo", units ="in", 
    width = 7, height = 6, res = 1200)
draw(network_map)
dev.off() 

#########################
#mTBI
#########################
#Construct an empty matrix
mat_mTBI <- matrix(nrow = 7, ncol = 7)
colnames(mat_mTBI) <- network_order
rownames(mat_mTBI) <- network_order

#Fill in the matrix
mat_mTBI[2:7,1] <- mean_conn_mTBI[1:6]; mat_mTBI[1,2:7] <- mean_conn_mTBI[1:6]
mat_mTBI[3:7,2] <- mean_conn_mTBI[7:11]; mat_mTBI[2,3:7] <- mean_conn_mTBI[7:11]
mat_mTBI[4:7,3] <- mean_conn_mTBI[12:15]; mat_mTBI[3,4:7] <- mean_conn_mTBI[12:15]
mat_mTBI[5:7,4] <- mean_conn_mTBI[16:18]; mat_mTBI[4,5:7] <- mean_conn_mTBI[16:18]
mat_mTBI[6:7,5] <- mean_conn_mTBI[19:20]; mat_mTBI[5,6:7] <- mean_conn_mTBI[19:20]
mat_mTBI[7,6] <- mean_conn_mTBI[21]; mat_mTBI[6,7] <- mean_conn_mTBI[21]

#Plot heatmap
col_fun = colorRamp2(seq(0.2, 1.4, length = 4), 
                     c("blue", "lightgreen", "yellow", "red"))
plot_title <- paste("mTBI Schaefer400 7Networks Mean FC matrix")

network_map_mTBI <- Heatmap(mat_mTBI, col = col_fun, name = "z", na_col = "firebrick",
                            row_order = rownames(mat_mTBI), column_order = colnames(mat_mTBI),
                            row_names_side = "left", column_title = plot_title,
                            heatmap_legend_param = list(at = c(0.2, 0.6, 1, 1.4)), 
                            cell_fun = function(j, i, x, y, width, height, fill) {
                              if(!is.na(mat_mTBI[i, j]))
                                grid.text(sprintf("%.2f", mat_mTBI[i, j]), x, y, gp = gpar(fontsize = 10))
                            })

png(filename = "FisherZ_mTBI_MeanFC_heatmap.png", type = "cairo", units ="in", 
    width = 7, height = 6, res = 1200)
draw(network_map_mTBI)
dev.off() 

#########################
#Control
#########################
#Construct an empty matrix
mat_cont <- matrix(nrow = 7, ncol = 7)
colnames(mat_cont) <- network_order
rownames(mat_cont) <- network_order

#Fill in the matrix
mat_cont[2:7,1] <- mean_conn_cont[1:6]; mat_cont[1,2:7] <- mean_conn_cont[1:6]
mat_cont[3:7,2] <- mean_conn_cont[7:11]; mat_cont[2,3:7] <- mean_conn_cont[7:11]
mat_cont[4:7,3] <- mean_conn_cont[12:15]; mat_cont[3,4:7] <- mean_conn_cont[12:15]
mat_cont[5:7,4] <- mean_conn_cont[16:18]; mat_cont[4,5:7] <- mean_conn_cont[16:18]
mat_cont[6:7,5] <- mean_conn_cont[19:20]; mat_cont[5,6:7] <- mean_conn_cont[19:20]
mat_cont[7,6] <- mean_conn_cont[21]; mat_cont[6,7] <- mean_conn_cont[21]

#Plot heatmap
col_fun = colorRamp2(seq(0.2, 1.4, length = 4), 
                     c("blue", "lightgreen", "yellow", "red"))
plot_title <- paste("Control Schaefer400 7Networks Mean FC matrix")

network_map_cont <- Heatmap(mat_cont, col = col_fun, name = "z", na_col = "firebrick",
                            row_order = rownames(mat_cont), column_order = colnames(mat_cont),
                            row_names_side = "left", column_title = plot_title,
                            heatmap_legend_param = list(at = c(0.2, 0.6, 1, 1.4)), 
                            cell_fun = function(j, i, x, y, width, height, fill) {
                              if(!is.na(mat_cont[i, j]))
                                grid.text(sprintf("%.2f", mat_cont[i, j]), x, y, gp = gpar(fontsize = 10))
                            })

png(filename = "FisherZ_Control_MeanFC_heatmap.png", type = "cairo", units ="in", 
    width = 7, height = 6, res = 1200)
draw(network_map_cont)
dev.off() 