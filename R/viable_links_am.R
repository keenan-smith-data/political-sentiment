here::i_am("R/viable_links_am.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
am_include <- c("salvo", "features", "memo")
# Viable Links
filtered_am <- sitemap_viable_links(sitemaps, short.source = "am", url.filter = am_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[1], stringr::regex("/\\w"))) ~ am_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[2], stringr::regex("/\\w"))) ~ am_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[3], stringr::regex("/\\w"))) ~ am_include[3],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[4], stringr::regex("/\\w"))) ~ am_include[4]
    ),
    css_title = ".tam__single-header-title",
    css_date = ".tam__single-header-meta-date",
    css_topics = ".tam__single-content-tags",
    css_author = ".tam__single-header-author",
    css_text = ".tam__single-content-output"
  )

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
