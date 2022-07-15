#Written by Isaac Chen for UFOV Functional Connectivity
#Clear all the variables in the environment
rm(list=ls())
#Print warnings as they come up for troubleshooting purposes
options(warn=1)

#Import libraries
library(tidyverse)

#Set relevant directories and file names
setwd("T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/")
src_fold <- "T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels/FisherZ"
group_summary_fname <- "T:/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates/ConnectivityMatrices_Schaefer2018_400Parcels_7Networks/FisherZ_WithinNetwork.csv"

#Read in subject session file
sub_list <- read_csv("ScansToPostProcess.csv") 

#Pre-define variables
prefix <- c("fsnwc50fwepia")
network_pairs <- c("Vis-Vis", "SomMot-SomMot", "DorsAttn-DorsAttn", "SalVentAttn-SalVentAttn", 
                   "Limbic-Limbic", "Cont-Cont", "Default-Default")

group_summary <- data.frame(matrix(ncol = 7, nrow = nrow(sub_list)))
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
  
  mat = data.matrix(data)
  colnames(mat) <- seq(1, 400, 1)
  rownames(mat) <- colnames(mat)
  
  #Extract all within network parcels and only get the lower tri
  #Here are the number of parcels in each network: 
  #Vis: 61x61; SomMot: 77x77; DorsAttn: 46x46; SalvenAttn: 47x47;
  #Limbic: 26x26; Cont: 52x52; Default: 91x91
  Vis_mat <- mat[1:61, 1:61]
  Vis_mat[Vis_mat == "Inf"] <- NA
  Vis_mat[upper.tri(Vis_mat)] <- NA
  group_summary$`Vis-Vis`[row] <- mean(Vis_mat, na.rm = TRUE) 
  
  SomMot_mat <- mat[62:138, 62:138]
  SomMot_mat[SomMot_mat == "Inf"] <- NA
  SomMot_mat[upper.tri(SomMot_mat)] <- NA
  group_summary$`SomMot-SomMot`[row] <- mean(SomMot_mat, na.rm = TRUE) 
  
  DorsAttn_mat <- mat[139:184, 139:184]
  DorsAttn_mat[DorsAttn_mat == "Inf"] <- NA
  DorsAttn_mat[upper.tri(DorsAttn_mat)] <- NA
  group_summary$`DorsAttn-DorsAttn`[row] <- mean(DorsAttn_mat, na.rm = TRUE) 
  
  SalVentAttn <- mat[185:231, 185:231]
  SalVentAttn[SalVentAttn == "Inf"] <- NA
  SalVentAttn[upper.tri(SalVentAttn)] <- NA
  group_summary$`SalVentAttn-SalVentAttn`[row] <- mean(SalVentAttn, na.rm = TRUE) 
  
  Limbic_mat <- mat[232:257, 232:257]
  Limbic_mat[Limbic_mat == "Inf"] <- NA
  Limbic_mat[upper.tri(Limbic_mat)] <- NA
  group_summary$`Limbic-Limbic`[row] <- mean(Limbic_mat, na.rm = TRUE) 
  
  Cont_mat <- mat[258:309, 258:309]
  Cont_mat[Cont_mat == "Inf"] <- NA
  Cont_mat[upper.tri(Cont_mat)] <- NA
  group_summary$`Cont-Cont`[row] <- mean(Cont_mat, na.rm = TRUE) 
  
  Default_mat <- mat[310:400, 310:400]
  Default_mat[Default_mat == "Inf"] <- NA
  Default_mat[upper.tri(Default_mat)] <- NA
  group_summary$`Default-Default`[row] <- mean(Default_mat, na.rm = TRUE) 
}
group_summary <- cbind(sub_list, group_summary)
group_summary <- subset(group_summary, select = -c(func))
write.csv(group_summary, group_summary_fname, row.names = FALSE)