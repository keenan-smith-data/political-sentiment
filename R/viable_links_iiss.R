here::i_am("R/viable_links_iiss.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_iiss.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
iiss_include <- c("online-analysis")

# Viable Links
filtered_iiss <- sitemap_viable_links(sitemaps, short.source = "iiss", url.filter = iiss_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), iiss_include[1], stringr::regex("/\\w"))) ~ iiss_include[1],
    ), css_text = ".reading",
    css_title = ".introduction",
    css_date = ".label--date",
    css_author = ".person__name",
    css_topics = NA
  )


library(RSelenium)

driver <- rsDriver(browser = "firefox", chromever = NULL, verbose = FALSE)

remote_driver <- driver[["client"]]

source(here::here("R", "write_to_db_js.R"))

write_to_db_js(filtered_iiss, scrape_db, "text_iiss", remDr = remote_driver, loop_start = 1L)
Sys.sleep(10)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)

remote_driver$close()
# stop the selenium server
driver[["server"]]$stop()
