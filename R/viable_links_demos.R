here::i_am("R/viable_links_demos.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_demos.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
demos_include <- c("blog", "press-release")

# Viable Links
filtered_demos <- sitemap_viable_links(sitemaps, short.source = "demos", url.filter = demos_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), demos_include[1], stringr::regex("/\\w"))) ~ demos_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), demos_include[2], stringr::regex("/\\w"))) ~ demos_include[2]
    ), css_text = tidytable::case_when(
      url_type == "blog" ~ ".article-detail-content",
      url_type == "press-release" ~ ".article-detail-content"
    ),
    css_title = tidytable::case_when(
      url_type == "blog" ~ '[class="field field--name-node-title field--type-ds field--label-hidden field__item"]',
      url_type == "press-release" ~ '[class="field field--name-node-title field--type-ds field--label-hidden field__item"]'
    ),
    css_date = tidytable::case_when(
      url_type == "blog" ~ ".datetime",
      url_type == "press-release" ~ ".datetime"
    ),
    css_author = tidytable::case_when(
      url_type == "blog" ~ '[class="field field--name-field-author field--type-entity-reference field--label-hidden field__items"]',
      url_type == "press-release" ~ '[class="field field--name-field-author field--type-entity-reference field--label-hidden field__items"]'
    ),
    css_topics = tidytable::case_when(
      url_type == "blog" ~ NA,
      url_type == "press-release" ~ NA
    )
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_demos, scrape_db, "text_demos", loop_start = 1L)
Sys.sleep(10)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
