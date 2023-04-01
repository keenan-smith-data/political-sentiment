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

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))

library(progress)
pb <- progress_bar$new(total = nrow(filtered_epi))

table_create <- create_art_table("text_epi", pol_sent_db)
DBI::dbExecute(pol_sent_db, table_create)

for (i in seq_along(filtered_epi$url)) {
  pb$tick()
  iteration_df <- article_pull_try_html(filtered_epi[i])
  iteration_df$pull_index <- i
  table_insert <- insert_into_art_table(iteration_df, "text_epi", pol_sent_db)
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
