text_collection_loop <- function(df) {
  
  data_list <- list(mode = "list", length(df$url))
  
  for (i in seq_along(df$url)) {
    iteration_df <- article_pull_df(df[i])
    iteration_df$i <- i
    data_list[[i]] <- iteration_df
  }
  
  final_data <- tidytable::bind_rows(data_list)
  return(final_data)
}