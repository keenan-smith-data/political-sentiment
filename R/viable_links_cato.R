here::i_am("R/viable_links_cato.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
cato_include <- c("blog", "commentary")
# Viable Links
filtered_cato <- sitemap_viable_links(sitemaps, short.source = "cato", url.filter = cato_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cato_include[1], stringr::regex("/\\w"))) ~ cato_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cato_include[2], stringr::regex("/\\w"))) ~ cato_include[2]
    ), css_text = tidytable::case_when(
      url_type == "commentary" ~ ".fs-lg",
      url_type == "blog" ~ ".fs-lg"
    ),
    css_title = tidytable::case_when(
      url_type == "commentary" ~ ".article-title",
      url_type == "blog" ~ ".h2"
    ),
    css_date = tidytable::case_when(
      url_type == "commentary" ~ ".meta",
      url_type == "blog" ~ ".date-time__date"
    ),
    css_author = tidytable::case_when(
      url_type == "commentary" ~ ".mb-2",
      url_type == "blog" ~ ".me-4"
    ),
    css_topics = tidytable::case_when(
      url_type == "commentary" ~ NA,
      url_type == "blog" ~ ".content-reference-link"
    )
  )

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)