here::i_am("R/viable_links_aei.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data","scrape_db","scrape_aei.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
aei_include <- c("articles", "carpe-diem", "op-eds")
# Viable Links
filtered_aei <- sitemap_viable_links(sitemaps, short.source = "aei", url.filter = aei_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[1], stringr::regex("/\\w"))) ~ aei_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[2], stringr::regex("/\\w"))) ~ aei_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[3], stringr::regex("/\\w"))) ~ aei_include[3]
    ),
    css_title = ".entry-title",
    css_date = "p.date",
    css_topics = ".p-3",
    css_author = "p.author",
    css_text = ".entry-content"
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 1L, loop_end = 5000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 5001L, loop_end = 10000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 10001L, loop_end = 15000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 15001L, loop_end = 20000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 20001L, loop_end = 25000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 25001L, loop_end = 30000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 30001L, loop_end = 35000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 35001L, loop_end = 40000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 40001L, loop_end = 45000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 45001L, loop_end = 50000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 50001L, loop_end = 55000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 55001L)

source(here::here("R", "copy_to_sql.R"))
copy_to_table(tbl_name = "text_aei", file_location = here::here("data", "scrape_db"), con = scrape_db)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
