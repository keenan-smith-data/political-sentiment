# Library Initiation
library(tidyverse)
library(rvest)

# URL Data Pull-In
jacobin <- read_rds("data/jacobin.rds")
features <- read_rds("data/americanmindfeatures.rds")
memos <- read_rds("data/americanmindmemos.rds")
salvos <- read_rds("data/americanmindsalvos.rds")
h_commentary <- read_rds("data/heritage_commentary.rds")
h_report <- read_rds("data/heritage_report.rds")
b_blog <- read_rds("data/brookings_blog.rds")

# Webscrape Functions
source("scraping_functions.R")

# American Mind Map Operations
memo_data_list <- map(.x = memos$url, .f = am_mind_pull_try)
salvo_data_list <- map(.x = salvos$url, .f = am_mind_pull_try)
feature_data_list <- map(.x = features$url, .f = am_mind_pull_try)

# Binding into a single Data Frame
memo_text <- bind_rows(memo_data_list)
salvo_text <- bind_rows(salvo_data_list)
feature_text <- bind_rows(feature_data_list)

write_rds(memo_text, "data/memo_text.rds", "gz", compression = 9L)
write_rds(salvo_text, "data/salvo_text.rds", "gz", compression = 9L)
write_rds(feature_text, "data/feature_text.rds", "gz", compression = 9L)
