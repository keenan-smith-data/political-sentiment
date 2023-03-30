# Library Initiation
here::i_am("R/data_pull_down.R")
library(here)
library(googledrive)

# Drive Authorization
drive_auth(token = drive_token())

# Function Block
links_raw <- drive_find(pattern = "links_raw")

raw_links_download <- function(drive_link) {
  drive_download(drive_link, path = here::here("data", drive_link))
}

purrr::map(.x = links_raw$name, raw_links_download)

linkchecker_files <- fs::dir_ls(here("data", "linkchecker"), regexp = "\\.csv$")
sitemap_files <- fs::dir_ls(here("data", "sitemap"), regexp = "\\.csv.gz$")
text_files <- fs::dir_ls(here("data", "text"), regexp = "\\.rds$")

message("Uploading Linkchecker Data Files to Drive")
tidytable::map(.x = linkchecker_files, .f = disk_to_drive)
message("Linkchecker Files Uploaded")

message("Uploading Sitemap Data Files to Drive")
tidytable::map(.x = sitemap_files, .f = disk_to_drive)
message("Sitemap Files Uploaded")

message("Uploading Text Data Files to Drive")
tidytable::map(.x = text_files, .f = disk_to_drive)
message("Text Files Uploaded")