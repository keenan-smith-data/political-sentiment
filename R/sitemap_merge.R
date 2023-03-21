here::i_am("R/sitemap_merge.R")

files <- fs::dir_ls(here::here("data", "sitemap"), regexp = "\\.csv.gz$")

links_list <- purrr::map(.x = files, .f = tidytable::fread)

links_sitemap <- bind_rows(links_list)

tidytable::fwrite(links_sitemap, here("data", "sitemap", "links_sitemap.csv.gz"))
