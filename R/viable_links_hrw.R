here::i_am("R/viable_links_hrw.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
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

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
