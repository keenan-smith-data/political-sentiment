here::i_am("R/viable_links_cbpp.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
cbpp_include <- c("blog", "research", "press/statements", "press/press-releases")
# Viable Links
filtered_cbpp <- sitemap_viable_links(sitemaps, short.source = "cbpp", url.filter = cbpp_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[1], stringr::regex("/\\w"))) ~ cbpp_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[2], stringr::regex("/\\w"))) ~ cbpp_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[3], stringr::regex("/\\w"))) ~ cbpp_include[3],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[4], stringr::regex("/\\w"))) ~ cbpp_include[4]
    ),
    css_text = tidytable::case_when(
      url_type == "blog" ~ '[class="block block-layout-builder block-field-blocknodeblogbody"]',
      url_type == "research" ~ '[class="block block-layout-builder block-field-blocknoderich-contentbody"]',
      url_type == "press/statements" ~ '[class="block block-layout-builder block-field-blocknoderich-contentbody"]',
      url_type == "press/press-releases" ~ '[class="block block-layout-builder block-field-blocknodepress-releasebody"]'
    ),
    css_title = tidytable::case_when(
      url_type == "blog" ~ '[class="block block-cbpp-core block-cbpp-formatted-title"]',
      url_type == "research" ~ '[class="block block-cbpp-core block-cbpp-formatted-title"]',
      url_type == "press/statements" ~ '[class="block block-cbpp-core block-cbpp-formatted-title"]',
      url_type == "press/press-releases" ~ '[class="block block-cbpp-core block-cbpp-formatted-title"]'
    ),
    css_date = tidytable::case_when(
      url_type == "blog" ~ ".datetime",
      url_type == "research" ~ ".datetime",
      url_type == "press/statements" ~ '[class="field field--name-field-statement-note field--type-text field--label-hidden field__item"]',
      url_type == "press/press-releases" ~ ".datetime"
    ),
    css_author = tidytable::case_when(
      url_type == "blog" ~ '[class="field field--name-field-display-title field--type-string field--label-hidden field__item"]',
      url_type == "research" ~ ".rich-content-author",
      url_type == "press/statements" ~ ".rich-content-author",
      url_type == "press/press-releases" ~ ".node__title"
    ),
    css_topics = tidytable::case_when(
      url_type == "blog" ~ '[class="field field--name-field-topics field--type-entity-reference field--label-inline field__items"]',
      url_type == "research" ~ '[class="field field--name-field-topics field--type-entity-reference field--label-above field__items"]',
      url_type == "press/statements" ~ '[class="field field--name-field-topics field--type-entity-reference field--label-above field__items"]',
      url_type == "press/press-releases" ~ '[class="field field--name-field-topics field--type-entity-reference field--label-above field__items"]'
    )
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_cbpp, pol_sent_db, "text_cbpp", loop_start = 6475L)

source(here::here("R", "export_db.R"))
export_statement <- export_db(here::here("data", "backup"), pol_sent_db)
message("Backing Up DB")
DBI::dbExecute(pol_sent_db, export_statement)

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)
