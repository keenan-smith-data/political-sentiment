here::i_am("R/viable_links_cap.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
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

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)

rm(
  pol_sent_db,
  sitemaps,
  source_table,
  sitemap_viable_links,
  cap_include
)
