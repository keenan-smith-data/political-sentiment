here::i_am("R/viable_links_osf.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
linkchecker <- dplyr::tbl(pol_sent_db, "linkchecker_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
osf_include <- c("voices")
# Viable Links
filtered_osf <- sitemap_viable_links(linkchecker, short.source = "osf", url.filter = osf_include) |>
  tidytable::filter(size > 1) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("org/"), osf_include[1], stringr::regex("/\\w"))) ~ osf_include[1],
    ), css_text = ".m-textBlock",
    css_title = "h1",
    css_date = ".m-articleMetaBar__body",
    css_author = ".a-articleAuthor__title",
    css_topics = ".a-articleMetaItem__body"
  ) |>
  tidytable::drop_na()

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))

library(progress)
pb <- progress_bar$new(total = nrow(filtered_osf))

table_create <- create_art_table("text_osf", pol_sent_db)
DBI::dbExecute(pol_sent_db, table_create)

for (i in seq_along(filtered_osf$url)) {
  pb$tick()
  iteration_df <- article_pull_try_html(filtered_osf[i])
  iteration_df$pull_index <- i
  table_insert <- insert_into_art_table(iteration_df, "text_osf", pol_sent_db)
  DBI::dbExecute(pol_sent_db, table_insert)
}

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
