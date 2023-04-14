here::i_am("R/viable_links_third.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_third.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
third_include <- c("memo", "report", "press", "blog")

# Viable Links
filtered_third <- sitemap_viable_links(sitemaps, short.source = "third", url.filter = third_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[1], stringr::regex("/\\w"))) ~ third_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[2], stringr::regex("/\\w"))) ~ third_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[3], stringr::regex("/\\w"))) ~ third_include[3],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[4], stringr::regex("/\\w"))) ~ third_include[4]
    ), css_text = tidytable::case_when(
      url_type == "memo" ~ ".Content",
      url_type == "report" ~ ".Content",
      url_type == "press" ~ ".col-lg-8",
      url_type == "blog" ~ ".Content"
    ),
    css_title = tidytable::case_when(
      url_type == "memo" ~ "h1.mb-4",
      url_type == "report" ~ "h1.mb-4",
      url_type == "press" ~ "h1.mb-4",
      url_type == "blog" ~ "h1.mb-4"
    ),
    css_date = tidytable::case_when(
      url_type == "memo" ~ ".published-at",
      url_type == "report" ~ ".published-at",
      url_type == "press" ~ ".published-at",
      url_type == "blog" ~ ".published-at"
    ),
    css_author = tidytable::case_when(
      url_type == "memo" ~ ".title",
      url_type == "report" ~ ".title",
      url_type == "press" ~ ".title",
      url_type == "blog" ~ ".title"
    ),
    css_topics = tidytable::case_when(
      url_type == "memo" ~ NA,
      url_type == "report" ~ NA,
      url_type == "press" ~ NA,
      url_type == "blog" ~ NA
    )
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_third, scrape_db, "text_third", loop_start = 1L)
Sys.sleep(10)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
