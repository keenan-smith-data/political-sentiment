here::i_am("R/viable_links_heritage.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data","scrape_db","scrape_heritage.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
heritage_include <- c("commentary", "report")
# Viable Links
filtered_heritage <- sitemap_viable_links(sitemaps, short.source = "heritage", url.filter = heritage_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), heritage_include[1], stringr::regex("/\\w"))) ~ heritage_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), heritage_include[2], stringr::regex("/\\w"))) ~ heritage_include[2]
    ), css_text = tidytable::case_when(
      url_type == "commentary" ~ ".article__body-copy",
      url_type == "report" ~ ".article__body-copy"
    ),
    css_title = tidytable::case_when(
      url_type == "commentary" ~ ".headline",
      url_type == "report" ~ ".article-headline"
    ),
    css_date = tidytable::case_when(
      url_type == "commentary" ~ ".article-general-info",
      url_type == "report" ~ ".article-general-info"
    ),
    css_author = tidytable::case_when(
      url_type == "commentary" ~ ".author-card__name",
      url_type == "report" ~ ".contributors-list__contributor-name"
    ),
    css_topics = tidytable::case_when(
      url_type == "commentary" ~ ".article__eyebrow",
      url_type == "report" ~ ".article__eyebrow"
    )
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 1L, loop_end = 5000L)
Sys.sleep(10)
write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 5001L, loop_end = 10000L)
Sys.sleep(10)
write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 10001L, loop_end = 15000L)
Sys.sleep(10)
write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 15001L, loop_end = 20000L)
Sys.sleep(10)
write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 20001L, loop_end = 25000L)
Sys.sleep(10)
write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 25001L, loop_end = 30000L)
Sys.sleep(10)
write_to_db(filtered_heritage, scrape_db, "text_heritage", loop_start = 30001L)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
