here::i_am("R/viable_links_epi.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
linkchecker <- dplyr::tbl(pol_sent_db, "linkchecker_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
epi_include <- c("blog")
# Viable Links
filtered_epi <- sitemap_viable_links(linkchecker, short.source = "epi", url.filter = epi_include) |>
  tidytable::filter(
    size > 1,
    stringr::str_detect(url, "wp-json|page|wp-content|/feed/", negate = TRUE)
  ) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), epi_include[1], stringr::regex("/\\w"))) ~ epi_include[1],
    ), css_text = ".blog-the_content",
    css_title = "h2",
    css_date = ".blog-byline",
    css_author = ".loop-author",
    css_topics = ".blog-tags"
  )

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
