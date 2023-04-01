here::i_am("R/viable_links_disc.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
disc_include <- c("a")
# Viable Links
filtered_disc <- sitemap_viable_links(sitemaps, short.source = "disc", url.filter = disc_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), disc_include[1], stringr::regex("/\\w"))) ~ disc_include[1]
    ), css_text = ".article-center",
    css_title = ".article-title",
    css_date = ".article-date",
    css_author = ".article-author",
    css_topics = ".article-categories"
  )

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))

table_create <- create_art_table("text_disc", pol_sent_db)
DBI::dbExecute(pol_sent_db, table_create)

for (i in 635:1626) {
  iteration_df <- article_pull_try_html(filtered_disc[i])
  iteration_df$pull_index <- i
  table_insert <- insert_into_art_table(iteration_df, "text_disc", pol_sent_db)
  tryCatch(
    {
      message(paste("Writing to DB", i))
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

