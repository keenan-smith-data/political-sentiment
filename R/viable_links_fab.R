here::i_am("R/viable_links_fab.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_fab.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
initial_helper <- function(.df, short.source = NULL, art.source = NULL) {
  if (is.null(art.source)) {
    .df |>
      dplyr::left_join(source_table, by = source_table$art_source) |>
      dplyr::filter(short_source == short.source) |>
      dplyr::collect()
  } else if (is.null(short.source)) {
    .df |>
      dplyr::filter(art_source == art.source) |>
      dplyr::collect()
  }
}

initial_look <- function(.df, short.source) {
  temp <- initial_helper(.df, short.source)
  urls <- tidytable::map_df(.x = temp$url, .f = xml2::url_parse)
  return(urls)
}

path_examination <- function(.df) {
  .df |>
    tidytable::separate_wider_delim(path, "/") |>
    tidytable::group_by(path2) |>
    tidytable::count(sort = T)
}
# Inclusion and Exclusion Vectors
fab_filter <- initial_look(sitemaps, "fab") |>
  path_examination() |>
  tidytable::filter(n > 1)

fab_exclude <- fab_filter[[1]]
rm(fab_filter)

# Viable Links
filtered_fab <- sitemap_viable_links(sitemaps, short.source = "fab", url.filter = fab_exclude, exclude = TRUE) |>
  tidytable::mutate(
    url_type = "article",
    css_text = ".content",
    css_title = ".article-header-title",
    css_date = ".article-meta-block-date",
    css_author = ".article-people-author-content-heading",
    css_topics = NA
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_fab, scrape_db, "text_fab", loop_start = 1L)
Sys.sleep(10)


# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
