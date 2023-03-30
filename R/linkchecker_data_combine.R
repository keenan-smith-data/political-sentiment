# Library Initiation
here::i_am("R/linkchecker_data_combine.R")
library(tidytable)
library(here)
library(googledrive)
library(stringr)

# Getting Authorization for Google Drive
drive_auth(token = drive_token())

# Determining Google File Position
links_raw <- drive_find(pattern = "links_raw")

# Downloading data files from drive if required
raw_links_download <- function(drive_link) {
  drive_download(drive_link, path = here::here("data", drive_link))
}

purrr::map(.x = links_raw$name, raw_links_download)

# Creating a vector of file names
files <- fs::dir_ls(here("data", "linkchecker"), regexp = "\\.csv$")

# Reading in CSV from Disk
links_raw_test <- map(.x = files, .f = fread, header = TRUE, fill = TRUE)

# Combining the List into a Data.table
links_raw_linkcheck <- tidytable::bind_rows(links_raw_test)

# Getting Link Data into a usable state
filtered_linkcheck <- links_raw_linkcheck |>
  tidytable::filter(result == "200 OK") |>
  tidytable::distinct(url, .keep_all = TRUE) |>
  tidytable::select(parentname, result, infostring, url, size) |>
  tidytable::mutate(test_source = as.factor(case_when(
    stringr::str_detect(parentname, "americanmind.org") ~ "American Mind",
    stringr::str_detect(parentname, "claremontreviewofbooks.com") ~ "Claremont Institute",
    stringr::str_detect(parentname, "jacobin.com") ~ "Jacobin",
    stringr::str_detect(parentname, "commonwealthfund.org") ~ "Commonwealth Fund",
    stringr::str_detect(parentname, "epi.org") ~ "EPI",
    stringr::str_detect(parentname, "heritage.org") ~ "Heritage Foundation",
    stringr::str_detect(parentname, "nationalreview.com") ~ "National Review",
    stringr::str_detect(parentname, "opensocietyfoundations.org") ~ "Open Society Foundations",
    stringr::str_detect(parentname, "thenation.com") ~ "The Nation"
  ))) |>
  tidytable::filter(!is.na(test_source))
# Writing Filtered Table to Disk
fwrite(filtered_linkcheck, here("data", "linkchecker", "links_pre-filtered_linkchecker.csv"))

drive_upload(here("data", "linkchecker", "links_pre-filtered_linkchecker.csv"), path = "~/political-sentiment/data/links_pre-filtered_linkchecker.csv")
