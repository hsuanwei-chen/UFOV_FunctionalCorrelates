#Written by Isaac Chen for Adrian's Resting-State project

#Define function used to plot mean connectivity heatmap
meanConnHeatmap_byNetwork <- function(meanConn, network_order, network_n, condition,
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
  
  #For loop for filling in the matrix
  index <- rev(1:(network_n-1))
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
  
  #Hard coding for filling in the matrix
  #mat[2:7,1] <- meanConn[1:6]; mat[1,2:7] <- meanConn[1:6]
  #mat[3:7,2] <- meanConn[7:11]; mat[2,3:7] <- meanConn[7:11]
  #mat[4:7,3] <- meanConn[12:15]; mat[3,4:7] <- meanConn[12:15]
  #mat[5:7,4] <- meanConn[16:18]; mat[4,5:7] <- meanConn[16:18]
  #mat[6:7,5] <- meanConn[19:20]; mat[5,6:7] <- meanConn[19:20]
  #mat[7,6] <- meanConn[21]; mat[6,7] <- meanConn[21]
  
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
  network_map_fname <- paste("FisherZ_meanFC_heatmap_", condition, ".png", sep = "")
  png(filename = network_map_fname, type = "cairo", units ="in", 
      width = 7, height = 6, res = 1200)
  draw(network_map)
  dev.off() 
}