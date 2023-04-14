here::i_am("R/viable_links_cfr.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_cfr.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
cfr_include <- c("article", "in-brief")

# Viable Links
filtered_cfr <- sitemap_viable_links(sitemaps, short.source = "cfr", url.filter = cfr_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cfr_include[1], stringr::regex("/\\w"))) ~ cfr_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cfr_include[2], stringr::regex("/\\w"))) ~ cfr_include[2]
    ), css_text = tidytable::case_when(
      url_type == "article" ~ ".body-content",
      url_type == "in-brief" ~ ".body-content"
    ),
    css_title = tidytable::case_when(
      url_type == "article" ~ ".article-header__title",
      url_type == "in-brief" ~ ".article-header__title"
    ),
    css_date = tidytable::case_when(
      url_type == "article" ~ ".article-header__date-ttr",
      url_type == "in-brief" ~ ".article-header__date-ttr"
    ),
    css_author = tidytable::case_when(
      url_type == "article" ~ ".article-header__link",
      url_type == "in-brief" ~ ".article-header__link"
    ),
    css_topics = tidytable::case_when(
      url_type == "article" ~ NA,
      url_type == "in-brief" ~ NA
    )
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_cfr, scrape_db, "text_cfr", loop_start = 1L)
Sys.sleep(10)


# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
