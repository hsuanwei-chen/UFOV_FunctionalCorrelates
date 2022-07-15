#Define function used to plot mean connectivity heatmap
meanConnHeatmap_byParcel <- function(meanConn, network_order, parcel_n, condition, atlas_name){
  #This function is designed to take in an average connectivity vector and generate a heatmap
  #It reads in a vector and reorders it into a matrix for plotting
  #It assumes that there are 400 parcels (400*399/2 = 79800)
  #
  #Here are the expected variables:
  # meanConn = a vector containing 79800 mean connectivity values
  # parcel_n = the number of unique parcels
  # condition = what the mean connectivity values are referring to {entire sample or subset of a group}
  # atlas_name = name of the atlas used (ex. Schaefer 2018's 400 Parcels)
  
  #Rename the column and row names to reflect the networks
  split <- data.frame(Network = rep(network_order, 
                                    c(61, 77, 46, 47, 26, 52, 91)))
  matching <- matching[order(matching$Network_Index),]
  
  #Create an empty matrix based on the number of networks
  mat <- matrix(nrow = parcel_n, ncol = parcel_n)
  colnames(mat) <- seq(1, 400, 1)
  rownames(mat) <- colnames(mat)
  
  #For loop for filling in the matrix
  index <- rev(1:(parcel_n-1))
  print("Code for filling each column...")
  for (i in 1:length(index)){
    if (i == 1){
      #Set up the indices for the first column
      start_index <- 1
      end_index <- index[i]
      
      #Print code for sanity checks
      log <- paste("mat[", i+1, ":", ncol(mat), ",", i, "] <- meanConn[", 
                   start_index, ":", end_index, "]", sep = "")
      print(log)
      
      #Fill in numbers for each column and row
      mat[(i+1):ncol(mat), i] <- meanConn[start_index:end_index] 
      mat[i, (i+1):ncol(mat)] <- meanConn[start_index:end_index] 
      
      #Set up the starting index for next column and row
      start_index <- start_index + index[i]
    }else{
      #Set up the end index for this column and row
      end_index <- end_index + index[i]
      
      #Print code for sanity checks
      log <- paste("mat[", i+1, ":", ncol(mat), ",", i, "] <- meanConn[", 
                   start_index, ":", end_index, "]", sep = "")
      print(log)
      
      #Fill in numbers for each column and row
      mat[(i+1):ncol(mat), i] <- meanConn[start_index:end_index] 
      mat[i, (i+1):ncol(mat)] <- meanConn[start_index:end_index] 
      
      #Set up the starting index for next column and row
      start_index <- start_index + index[i]
    }
  }
  
  #Define heatmap color scheme and plot title
  #This function also assumes values are between -0.4 and 2.0
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
  plot_title <- paste(condition, atlas_name, "Mean FC matrix")
  
  #Plot heatmap
  #If you change the range of the values, please also adjust heatmap_legend_param
  parcel_map <- Heatmap(mat, col = col_fun, name = "z", na_col = "firebrick",
                        row_split = split, row_gap = unit(0.8, "mm"),
                        column_split = split, column_gap = unit(0.8, "mm"),
                        border = TRUE, row_title_rot = 0, column_title = plot_title,
                        row_title_gp = gpar(fontsize = 12),
                        row_order = rownames(mat), column_order = colnames(mat),
                        show_row_names = FALSE, show_column_names = FALSE,
                        left_annotation = row_ha, top_annotation = column_ha,
                        heatmap_legend_param = list(at = c(-0.4, 0.4, 1.2, 2.0)))
  
  #Save the heatmap
  parcel_map_fname <- paste("FisherZ_meanFC_heatmap_", condition, ".png", sep = "")
  png(filename = parcel_map_fname, type = "cairo", units ="in", 
      width = 8, height = 6, res = 1200)
  draw(parcel_map)
  dev.off()
}