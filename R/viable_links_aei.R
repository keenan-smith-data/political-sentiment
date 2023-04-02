here::i_am("R/viable_links_aei.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
aei_include <- c("articles", "carpe-diem", "op-eds")
# Viable Links
filtered_aei <- sitemap_viable_links(sitemaps, short.source = "aei", url.filter = aei_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[1], stringr::regex("/\\w"))) ~ aei_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[2], stringr::regex("/\\w"))) ~ aei_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[3], stringr::regex("/\\w"))) ~ aei_include[3]
    ),
    css_title = ".entry-title",
    css_date = "p.date",
    css_topics = ".p-3",
    css_author = "p.author",
    css_text = ".entry-content"
  )

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))
source(here::here("R", "write_to_db.R"))

write_to_db(filtered_aei, pol_sent_db, "text_aei")

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
