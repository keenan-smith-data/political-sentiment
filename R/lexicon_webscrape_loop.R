# Library Initiation
library(tidyverse)
library(rvest)

# URL Data Pull-In
jacobin <- read_rds("data/jacobin.rds")
h_commentary <- read_rds("data/heritage_commentary.rds")
h_report <- read_rds("data/heritage_report.rds")
b_blog <- read_rds("data/brookings_blog.rds")

# Webscrape Functions
source("scraping_functions.R")

# Creating a vector for Splitting and Sampling Order
numbers <- c(1:10)

set.seed(1234)

# Splitting the Large URL Lists
j_list <- data_split(jacobin)
h_com_list <- data_split(h_commentary)
h_rep_list <- data_split(h_report)
b_list <- data_split(b_blog)

# Creating a Random Orde
h_order <- sample(numbers, 10)
j_order <- sample(numbers, 10)
b_order <- sample(numbers, 10)

# Creating Empty Lists for Looping with the Large Lists
j_data_list <- list()
h_com_data_list <- list()
h_rep_data_list <- list()
b_data_list <- list()

# For Loop for Scraping Large Amounts of URLs
for (i in numbers) {
  j_temp <- map(.x = j_list[[j_order[i]]]$url, .f = j_pull_try)
  j_temp_df <- bind_rows(j_temp)
  j_title <- stringr::str_c("data/iterations/jacobin_iteration_", i, ".rds")
  readr::write_rds(j_temp_df, file = j_title, "gz", compression = 9L)
  j_temp_df$i <- i
  j_data_list[[i]] <- j_temp_df

  h_com_temp <- map(.x = h_com_list[[h_order[i]]]$url, .f = h_com_pull_try)
  h_com_temp_df <- bind_rows(h_com_temp)
  h_com_title <- stringr::str_c("data/iterations/h_com_iteration_", i, ".rds")
  readr::write_rds(h_com_temp_df, file = h_com_title, "gz", compression = 9L)
  h_com_temp_df$i <- i
  h_com_data_list[[i]] <- h_com_temp_df

  h_rep_temp <- map(.x = h_rep_list[[h_order[i]]]$url, .f = h_rep_pull_try)
  h_rep_temp_df <- bind_rows(h_rep_temp)
  h_rep_title <- stringr::str_c("data/iterations/h_rep_iteration_", i, ".rds")
  readr::write_rds(h_rep_temp_df, file = h_rep_title, "gz", compression = 9L)
  h_rep_temp_df$i <- i
  h_rep_data_list[[i]] <- h_rep_temp_df

  b_temp <- map(.x = b_list[[b_order[i]]]$url, .f = b_pull_try)
  b_temp_df <- bind_rows(b_temp)
  b_title <- stringr::str_c("data/iterations/brookings_iteration_", i, ".rds")
  readr::write_rds(b_temp_df, file = b_title, "gz", compression = 9L)
  b_temp_df$i <- i
  b_data_list[[i]] <- b_temp_df
}

# Binding the Large Lists into a Single Dataframe
jacobin_text <- bind_rows(j_data_list)
h_com_text <- bind_rows(h_com_data_list)
h_rep_text <- bind_rows(h_rep_data_list)
b_text <- bind_rows(b_data_list)

# Writing all Data to Disk
write_rds(jacobin_text, "data/jacobin_text.rds", "gz", compression = 9L)
write_rds(h_com_text, "data/heritage_com_text.rds", "gz", compression = 9L)
write_rds(h_rep_text, "data/heritage_rep_text.rds", "gz", compression = 9L)
write_rds(b_text, "data/brooking_text.rds", "gz", compression = 9L)
