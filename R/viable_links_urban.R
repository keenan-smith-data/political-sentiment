here::i_am("R/viable_links_urban.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
urban_include <- c("urban-wire")
# Viable Links
filtered_urban <- sitemap_viable_links(sitemaps, short.source = "urban", url.filter = urban_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), urban_include[1], stringr::regex("/\\w"))) ~ urban_include[1]
    ), css_text = '[data-block-plugin-id="urban-blocks-body-or-summary"]',
    css_title = '[element="h1"]',
    css_date = ".date",
    css_author = ".mb-2",
    css_topics = '[class="inline-block mr-4 mb-4"]'
  )

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
