here::i_am("R/viable_links_hrw.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data","scrape_db","scrape_hrw.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
hrw_include <- c("news", "report", "world-report")
# Viable Links
filtered_hrw <- sitemap_viable_links(sitemaps, short.source = "hrw", url.filter = hrw_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("org/"), hrw_include[1], stringr::regex("/\\d"))) ~ hrw_include[1],
      stringr::str_detect(url, paste0(stringr::regex("org/"), hrw_include[2], stringr::regex("/\\d"))) ~ hrw_include[2],
      stringr::str_detect(url, paste0(stringr::regex("org/"), hrw_include[3], stringr::regex("/\\d"))) ~ hrw_include[3]
    ), css_text = tidytable::case_when(
      url_type == "report" ~ '[class="rich-text mx-auto"]',
      url_type == "world-report" ~ '[class="rich-text mx-auto"]',
      url_type == "news" ~ ".article-body"
    ),
    css_title = tidytable::case_when(
      url_type == "report" ~ ".report-header__title",
      url_type == "world-report" ~ ".chapter-header__title",
      url_type == "news" ~ ".news-header__main"
    ),
    css_date = tidytable::case_when(
      url_type == "report" ~ ".report-header__dateline-date",
      url_type == "world-report" ~ ".chapter-header__subtitle",
      url_type == "news" ~ ".news-header__dateline-date"
    ),
    css_author = tidytable::case_when(
      url_type == "report" ~ ".byline__name",
      url_type == "world-report" ~ ".byline__name",
      url_type == "news" ~ ".byline__name"
    ),
    css_topics = tidytable::case_when(
      url_type == "report" ~ ".tag-block",
      url_type == "world-report" ~ ".toc-simple__item",
      url_type == "news" ~ ".tag-block"
    )
  ) |>
  tidytable::drop_na()


source(here::here("R", "write_to_db.R"))

write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 1L, loop_end = 5000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 5001L, loop_end = 10000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 10001L, loop_end = 15000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 15001L, loop_end = 20000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 20001L, loop_end = 25000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 25001L, loop_end = 30000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 30001L, loop_end = 35000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 35001L, loop_end = 40000L)
Sys.sleep(10)
write_to_db(filtered_hrw, scrape_db, "text_hrw", loop_start = 40001L)

# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
