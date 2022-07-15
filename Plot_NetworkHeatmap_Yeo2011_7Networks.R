rm(list=ls())

#Import libraries
library(tidyverse)
library(ComplexHeatmap)
library(circlize)

#Set relevant directories and file names
#DTS
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState")
src_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Yeo2011_7Networks/FisherZ"
dest_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Yeo2011_7Networks/FisherZ_heatmap"
group_summary_fname <- "T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState/ConnectivityMatrices_Yeo2011_7Networks/FisherZ_group_summary.csv"

#UFOV
#setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState")
#src_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Yeo2011_7Networks/FisherZ"
#dest_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Yeo2011_7Networks/FisherZ_heatmap"
#group_summary_fname <- "T:/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState/ConnectivityMatrices_Yeo2011_7Networks/FisherZ_group_summary.csv"

#Read in subject session file
sub_list <- read_csv("ScansToPostProcess.csv") 

#Pre-define variables
prefix <- c("fsnwc50fwepia")
network_order <-  factor(c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"),
                         levels = c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"))
network_pairs <- c("Vis-SomMot", "Vis-DorsAttn", "Vis-SalVentAttn", "Vis-Limbic", "Vis-Cont", "Vis-Default",
                   "SomMot-DorsAttn", "SomMot-SalVentAttn", "SomMot-Limbic", "SomMot-Cont", "SomMot-Default",
                   "DorsAttn-SalVentAttn", "DorsAttn-Limbic", "DorsAttn-Cont", "DorsAttn-Default",
                   "SalVentAttn-Limbic", "SalVentAttn-Cont", "SalVentAttn-Default",
                   "Limbic-Cont", "Limbic-Default",
                   "Cont-Default")

group_summary <- data.frame(matrix(ncol = 21, nrow = nrow(sub_list)))
colnames(group_summary) <- network_pairs

for(row in 1:nrow(sub_list)){
  #Print out which subject session is being worked on
  sub_log <- sprintf("%i. Working on %s %s %s", row, sub_list$subject_id[row],
                     sub_list$sess_date[row], sub_list$task_dir[row])
  print(sub_log)
  
  #Identify which task
  if(sub_list$task_dir[row] == "ftap"){
    rename_task <- "task-ftap_bold"
  }else{
    rename_task <- "task-rest_bold"
  }

  #Create path for each subject session's correlation matrix
  mat_fname <- paste(src_fold, "/", prefix, sub_list$subject_id[row], "_", sub_list$sess_date[row], 
                     "_", rename_task, "_run-01_fisherZ_conn.csv", sep = "")
  data <- read_csv(mat_fname, col_names = FALSE, col_types = cols())
  data[data == "Inf"] <- NA
  
  #Rename the column and row names to reflect the networks
  mat <-  data.matrix(data)
  colnames(mat) <- network_order
  rownames(mat) <- network_order
  
  col_fun = colorRamp2(seq(-0.4, 2.0, length = 4),
                       c("blue", "lightgreen", "yellow", "red"))
  plot_title <- paste(sub_list$subject_id[row], sub_list$sess_date[row], sub_list$task_dir[row],
                      "Yeo2011 7Networks FC matrix")
  
  network_map <- Heatmap(mat, col = col_fun, name = "z", na_col = "firebrick",
                         row_order = rownames(mat), column_order = colnames(mat),
                         row_names_side = "left", column_title = plot_title,
                         heatmap_legend_param = list(at = c(-0.4, 0.4, 1.2, 2.0)), 
                         cell_fun = function(j, i, x, y, width, height, fill) {
                           if(!is.na(mat[i, j]))
                             grid.text(sprintf("%.2f", mat[i, j]), x, y, gp = gpar(fontsize = 10))
                         })
  
  dest_fname <- paste(dest_fold, "/", prefix, sub_list$subject_id[row], "_", sub_list$sess_date[row], 
                      "_", rename_task, "_run-01_heatmap.png", sep = "")
  png(filename = dest_fname, type = "cairo", units ="in", 
      width = 7, height = 6, res = 1200)
  draw(network_map)
  dev.off() 
  
  #Replace the upper triangle as NA
  mat[upper.tri(mat)] <- NA
  colnames(mat) <- network_order

  #Transform matrix to vector and remove all the NAs
  vec <- c(mat)
  vec <- vec[!is.na(vec)]
  
  #Append vector to group summary dataframe
  group_summary[row,] <- vec
}
group_summary <- cbind(sub_list, group_summary)
group_summary <- subset(group_summary, select = -c(func))
write.csv(group_summary, group_summary_fname, row.names = FALSE)
