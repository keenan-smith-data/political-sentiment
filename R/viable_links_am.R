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

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))

library(progress)
pb <- progress_bar$new(total = nrow(filtered_am))

table_create <- create_art_table("text_am", pol_sent_db)
DBI::dbExecute(pol_sent_db, table_create)

for (i in seq_along(filtered_am$url)) {
  pb$tick()
  iteration_df <- article_pull_try_html(filtered_am[i])
  iteration_df$pull_index <- i
  table_insert <- insert_into_art_table(iteration_df, "text_am", pol_sent_db)
  tryCatch(
    {
      message("Writing to DB")
      DBI::dbExecute(pol_sent_db, table_insert)
    },
    error = function(e) {
      message(e)
    },
    warning = function(w) {
      message(w)
    }, finally = {
      message("\nContinuing to Next URL")
    }
  )
}

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
