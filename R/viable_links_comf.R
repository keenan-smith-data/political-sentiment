here::i_am("R/viable_links_comf.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
linkchecker <- dplyr::tbl(pol_sent_db, "linkchecker_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
comf_include <- c("blog", "publications")
# Viable Links
filtered_comf <- sitemap_viable_links(linkchecker, short.source = "comf", url.filter = comf_include) |>
  tidytable::filter(size > 1) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), comf_include[1], stringr::regex("/\\w"))) ~ comf_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), comf_include[2], stringr::regex("/\\w"))) ~ comf_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), comf_include[3], stringr::regex("/\\w"))) ~ comf_include[3]
    ), css_text = tidytable::case_when(
      url_type == "publications" ~ ".article-body__content",
      url_type == "blog" ~ ".article-body__content"
    ),
    css_title = tidytable::case_when(
      url_type == "publications" ~ ".publication-hero__title",
      url_type == "blog" ~ ".publication-hero__title"
    ),
    css_date = tidytable::case_when(
      url_type == "publications" ~ "[datetime]",
      url_type == "blog" ~ "[datetime]"
    ),
    css_author = tidytable::case_when(
      url_type == "publications" ~ ".authors__links",
      url_type == "blog" ~ ".experts-siderail__name"
    ),
    css_topics = tidytable::case_when(
      url_type == "publications" ~ ".publication-details__topics",
      url_type == "blog" ~ ".publication-details__topics"
    )
  )

library(RSelenium)

driver <- rsDriver(browser = "firefox", chromever = NULL)

remote_driver <- driver[["client"]]

source(here::here("R", "text_sql_statements.R"))
source(here::here("R", "scraping_helpers.R"))
source(here::here("R", "article_pull_js.R"))
source(here::here("R", "write_to_db_js.R"))

write_to_db_js(filtered_comf, pol_sent_db, "text_comf", remDr = remote_driver)

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)

remote_driver$close()
# stop the selenium server
driver[["server"]]$stop()
