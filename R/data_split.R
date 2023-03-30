# Function for Splitting large datasets
data_split <- function(data, n_groups = 10) {
  temp <- data
  temp$group <- 1:nrow(temp) %% n_groups + 1
  temp_list <- split(temp, temp$group)
  return(temp_list)
}
