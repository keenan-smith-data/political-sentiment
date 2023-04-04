# Library Initiation
here::i_am("R/data_upload.R")
library(here)
library(googledrive)

# Drive Authorization
drive_auth(token = drive_token())

# Function Block
disk_to_drive <- function(file_path, over.write = TRUE) {
  temp <- stringr::str_split(file_path, "/")[[1]][9]
  googledrive::drive_upload(file_path, path = glue::glue("~/political-sentiment/data/{temp}"), overwrite = over.write)
}

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