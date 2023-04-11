here::i_am("R/viable_links_wilson.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrape_db", "scrape_wilson.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
wilson_include <- c("article", "blog-post")

# Viable Links
filtered_wilson <- sitemap_viable_links(sitemaps, short.source = "wilson", url.filter = wilson_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), wilson_include[1], stringr::regex("/\\w"))) ~ wilson_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), wilson_include[2], stringr::regex("/\\w"))) ~ wilson_include[2]
    ), css_text = tidytable::case_when(
      url_type == "article" ~ ".text-block-inner",
      url_type == "blog-post" ~ ".text-block-inner"
    ),
    css_title = tidytable::case_when(
      url_type == "article" ~ ".insight-detail-hero-title",
      url_type == "blog-post" ~ ".insight-detail-hero-title"
    ),
    css_date = tidytable::case_when(
      url_type == "article" ~ '[class="insight-detail-hero-author-byline-text -date"]',
      url_type == "blog-post" ~ '[class="insight-detail-hero-author-byline-text -date"]'
    ),
    css_author = tidytable::case_when(
      url_type == "article" ~ ".insight-detail-hero-author-byline-link-text",
      url_type == "blog-post" ~ ".insight-detail-hero-author-byline-link-text"
    ),
    css_topics = tidytable::case_when(
      url_type == "article" ~ NA,
      url_type == "blog-post" ~ NA
    )
  )

# purrr::walk(.x = filtered_wilson$url[778:780], .f = browseURL)
source(here::here("R", "write_to_db.R"))

write_to_db(filtered_wilson, scrape_db, "text_wilson", loop_start = 1764L, loop_end = 5000L)
Sys.sleep(10)
write_to_db(filtered_wilson, scrape_db, "text_wilson", loop_start = 5001L)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
