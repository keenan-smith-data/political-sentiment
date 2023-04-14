here::i_am("R/viable_links_cap.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data","scrape_db","scrape_cap.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
cap_include <- c("article")
# Viable Links
filtered_cap <- sitemap_viable_links(sitemaps, short.source = "cap", url.filter = cap_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cap_include[1], stringr::regex("/\\w"))) ~ cap_include[1]
    ),
    css_text = '[class="wysiwyg -xw:4 -mx:a"]',
    css_title = ".header2-title",
    css_date = '[class="-t:9 -tt:u -c:d2t"]',
    css_author = '[class="authors1-list -as:2 -t:10"]',
    css_topics = '[class="-c:a5t term_link_listing"]'
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_cap, scrape_db, "text_cap", loop_start = 1L, loop_end = 5000L)
Sys.sleep(10)
write_to_db(filtered_cap, scrape_db, "text_cap", loop_start = 5001L, loop_end = 10000L)
Sys.sleep(10)
write_to_db(filtered_cap, scrape_db, "text_cap", loop_start = 10001L, loop_end = 15000L)
Sys.sleep(10)
write_to_db(filtered_cap, scrape_db, "text_cap", loop_start = 15001L, loop_end = 20000L)
Sys.sleep(10)
write_to_db(filtered_cap, scrape_db, "text_cap", loop_start = 20001L)


# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
