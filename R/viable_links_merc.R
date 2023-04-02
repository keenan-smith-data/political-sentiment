here::i_am("R/viable_links_merc.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
merc_include <- c("expert-commentary")
# Viable Links
filtered_merc <- sitemap_viable_links(sitemaps, short.source = "merc", url.filter = merc_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), merc_include[1], stringr::regex("/\\w"))) ~ merc_include[1]
    ), css_text = ".coh-ce-cpt_text-ec73cf93",
    css_title = "h1.coh-heading",
    css_date = "[datetime]",
    css_author = ".coh-style-byline",
    css_topics = '[data-item="category"]'
  )

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_html.R"))
source(here::here("R", "write_to_db.R"))

write_to_db(filtered_merc, pol_sent_db, "text_merc")

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
