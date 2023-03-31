here::i_am("R/viable_links_mani.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
mani_include <- c("html")
# Viable Links
filtered_mani <- sitemap_viable_links(sitemaps, short.source = "mani", url.filter = mani_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), mani_include[1], stringr::regex("/\\w"))) ~ mani_include[1]
    ), css_text = ".l_ipage-content",
    css_title = "h1.title",
    css_date = ".date",
    css_author = ".authors",
    css_topics = ".topics"
  )

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
