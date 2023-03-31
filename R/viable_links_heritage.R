here::i_am("R/viable_links_heritage.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
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

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
