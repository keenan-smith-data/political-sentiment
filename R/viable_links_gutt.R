here::i_am("R/viable_links_gutt.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
gutt_include <- c("news-release")
# Viable Links
filtered_gutt <- sitemap_viable_links(sitemaps, short.source = "gutt", url.filter = gutt_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), gutt_include[1], stringr::regex("/\\w"))) ~ gutt_include[1]
    ), css_text = ".c-content",
    css_title = ".c-page-title--article-title",
    css_date = ".c-metadata-tag--solid-black",
    css_author = ".fn",
    css_topics = ".field__item"
  )

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))

library(progress)
pb <- progress_bar$new(total = nrow(filtered_gutt))

table_create <- create_art_table("text_gutt", pol_sent_db)
DBI::dbExecute(pol_sent_db, table_create)

for (i in seq_along(filtered_gutt$url)) {
  pb$tick()
  iteration_df <- article_pull_try_html(filtered_gutt[i])
  iteration_df$pull_index <- i
  table_insert <- insert_into_art_table(iteration_df, "text_gutt", pol_sent_db)
  DBI::dbExecute(pol_sent_db, table_insert)
}

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
