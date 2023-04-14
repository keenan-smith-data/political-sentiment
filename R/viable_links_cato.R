here::i_am("R/viable_links_cato.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_cato.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
cato_include <- c("blog", "commentary")
# Viable Links
filtered_cato <- sitemap_viable_links(sitemaps, short.source = "cato", url.filter = cato_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cato_include[1], stringr::regex("/\\w"))) ~ cato_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cato_include[2], stringr::regex("/\\w"))) ~ cato_include[2]
    ), css_text = tidytable::case_when(
      url_type == "commentary" ~ ".fs-lg",
      url_type == "blog" ~ ".fs-lg"
    ),
    css_title = tidytable::case_when(
      url_type == "commentary" ~ ".article-title",
      url_type == "blog" ~ ".h2"
    ),
    css_date = tidytable::case_when(
      url_type == "commentary" ~ ".meta",
      url_type == "blog" ~ ".date-time__date"
    ),
    css_author = tidytable::case_when(
      url_type == "commentary" ~ ".mb-2",
      url_type == "blog" ~ ".me-4"
    ),
    css_topics = tidytable::case_when(
      url_type == "commentary" ~ NA,
      url_type == "blog" ~ ".content-reference-link"
    )
  )

library(RSelenium)

driver <- rsDriver(browser = "firefox", chromever = NULL, verbose = FALSE)

remote_driver <- driver[["client"]]

source(here::here("R", "write_to_db_js.R"))

# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 1L, loop_end = 5000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 5001L, loop_end = 10000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 10001L, loop_end = 15000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 15001L, loop_end = 20000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 20001L, loop_end = 15000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 25001L, loop_end = 30000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 30001L, loop_end = 35000L)
# Sys.sleep(10)
# write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 35001L, loop_end = 40000L)
# Sys.sleep(10)
write_to_db_js(filtered_cato, scrape_db, "text_cato", remDr = remote_driver, loop_start = 40001L)
Sys.sleep(10)


# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)

remote_driver$close()
# stop the selenium server
driver[["server"]]$stop()
