#Written by Isaac Chen for Adrian's Resting-State project
#Clear all the variables in the environment
rm(list=ls())
#Print warnings as they come up for troubleshooting purposes
options(warn=1)

#Import libraries
library(tidyverse)
library(ComplexHeatmap)
library(circlize)

#Set relevant directories and file names
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates")
src_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels/FisherZ"
dest_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels/FisherZ_heatmap"
group_summary_fname <- "T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels/FisherZ_group_summary.csv"

#Create plot folder
dir.create(dest_fold)

#Read in subject session file
sub_list <- read_csv("ScansToPostProcess.csv") 
matching = read_csv("T:/Stacy/Scans/Scripts/UFOV_FunctionalCorrelates/Schaefer2018_400Parcels_Matching.csv")

#Pre-define variables
prefix <- c("fsnwc50fwepia")
network_order <-  factor(c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"),
                         levels = c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default"))

group_summary <- data.frame(matrix(ncol = 79800, nrow = nrow(sub_list)))

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
  split <- data.frame(Network = rep(network_order, 
                                    c(61, 77, 46, 47, 26, 52, 91)))
  matching <- matching[order(matching$Network_Index),]
  
  mat = data.matrix(data)
  colnames(mat) <- seq(1, 400, 1)
  rownames(mat) <- colnames(mat)
  
  mat <- mat[matching$Schaefer_Index, matching$Schaefer_Index]
  
  plot_title <- paste(sub_list$subject_id[row], sub_list$sess_date[row], sub_list$task_dir[row],
                      "Schaefer400 FC matrix")
  
  #Specify column and row annotations as well as correlation colors
  column_ha = HeatmapAnnotation(df = split,
                                col = list(Network = c("Vis" = "#781286", "SomMot" = "#4682B4", 
                                                       "DorsAttn" = "#00760E", "SalVentAttn" = "#C43AFA",
                                                       "Limbic" = "#DCF8A4", "Cont" = "#E69440", "Default" = "#CD3E4E")),
                                show_annotation_name = FALSE, show_legend = FALSE)
  row_ha = rowAnnotation(df = split,
                         col = list(Network = c("Vis" = "#781286", "SomMot" = "#4682B4", 
                                                "DorsAttn" = "#00760E", "SalVentAttn" = "#C43AFA",
                                                "Limbic" = "#DCF8A4", "Cont" = "#E69440", "Default" = "#CD3E4E")),
                         width = unit(1, "cm"), show_annotation_name = FALSE, show_legend = FALSE)
  col_fun = colorRamp2(seq(-0.4, 2.0, length = 4),
                       c("blue", "lightgreen", "yellow", "red"))
  
  #Specify all parameters for the heatmap
  parcel_map <- Heatmap(mat, col = col_fun, name = "z", na_col = "firebrick",
                        row_split = split, row_gap = unit(0.8, "mm"),
                        column_split = split, column_gap = unit(0.8, "mm"),
                        border = TRUE, row_title_rot = 0, column_title = plot_title,
                        row_title_gp = gpar(fontsize = 12),
                        row_order = rownames(mat), column_order = colnames(mat),
                        show_row_names = FALSE, show_column_names = FALSE,
                        left_annotation = row_ha, top_annotation = column_ha,
                        heatmap_legend_param = list(at = c(-0.4, 0.4, 1.2, 2.0)))
  
  #Save your work
  dest_fname <- paste(dest_fold, "/", prefix, sub_list$subject_id[row], "_", sub_list$sess_date[row], 
                      "_", rename_task, "_run-01_heatmap.png", sep = "")
  png(filename = dest_fname, type = "cairo", units ="in", 
      width = 8, height = 6, res = 1200)
  draw(parcel_map)
  dev.off()
  
  #Replace the upper triangle as NA
  mat[upper.tri(mat)] <- NA
  #colnames(mat) <- network_order
  
  #Transform matrix to vector and remove all the NAs
  vec <- c(mat)
  vec <- vec[!is.na(vec)]
  
  #Append vector to group summary dataframe
  group_summary[row,] <- vec
}
group_summary <- cbind(sub_list, group_summary)
group_summary <- subset(group_summary, select = -c(func))
write.csv(group_summary, group_summary_fname, row.names = FALSE)