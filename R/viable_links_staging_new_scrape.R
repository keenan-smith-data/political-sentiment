here::i_am("R/viable_links_.R")

# Connecting to DuckDB
scrape_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "scrapedb", ".duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(scrape_db, "sitemap_data")
source_table <- dplyr::tbl(scrape_db, "source_table")
# Function Block for Obtaining Viable Links
# Function Block for Obtaining Viable Links
source(here::here("R", "sitemap_viable_links.R"))
# Inclusion and Exclusion Vectors
wilson_include <- c("article", "blog-post")
demos_include <- c("blog", "press-release")
iiss_include <- c("online-analysis")
third_include <- c("memo", "report", "press", "blog")
cfr_include <- c("article", "in-brief")

fab_filter <- initial_look(sitemaps, "fab") |>
  path_examination() |>
  tidytable::filter(n > 1)

fab_exclude <- fab_filter[[1]]
rm(fab_filter)

# Viable Links
filtered_wilson <- sitemap_viable_links(sitemaps, short.source = "wilson", url.filter = wilson_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), wilson_include[1], stringr::regex("/\\w"))) ~ wilson_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), wilson_include[2], stringr::regex("/\\w"))) ~ wilson_include[2]
    ), css_text = case_when(
      url_type == "article" ~ ".text-block-inner",
      url_type == "blog-post" ~ ".text-block-inner"
    ),
    css_title = case_when(
      url_type == "article" ~ ".insight-detail-hero-title",
      url_type == "blog-post" ~ ".insight-detail-hero-title"
    ),
    css_date = case_when(
      url_type == "article" ~ '[class="insight-detail-hero-author-byline-text -date"]',
      url_type == "blog-post" ~ '[class="insight-detail-hero-author-byline-text -date"]'
    ),
    css_author = case_when(
      url_type == "article" ~ ".insight-detail-hero-author-byline-link-text",
      url_type == "blog-post" ~ ".insight-detail-hero-author-byline-link-text"
    ),
    css_topics = case_when(
      url_type == "article" ~ NA,
      url_type == "blog-post" ~ NA
    )
  )

filtered_demos <- sitemap_viable_links(sitemaps, short.source = "demos", url.filter = demos_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), demos_include[1], stringr::regex("/\\w"))) ~ demos_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), demos_include[2], stringr::regex("/\\w"))) ~ demos_include[2]
    ), css_text = case_when(
      url_type == "blog" ~ ".article-detail-content",
      url_type == "press-release" ~ ".article-detail-content"
    ),
    css_title = case_when(
      url_type == "blog" ~ '[class="field field--name-node-title field--type-ds field--label-hidden field__item"]',
      url_type == "press-release" ~ '[class="field field--name-node-title field--type-ds field--label-hidden field__item"]'
    ),
    css_date = case_when(
      url_type == "blog" ~ ".datetime",
      url_type == "press-release" ~ ".datetime"
    ),
    css_author = case_when(
      url_type == "blog" ~ '[class="field field--name-field-author field--type-entity-reference field--label-hidden field__items"]',
      url_type == "press-release" ~ '[class="field field--name-field-author field--type-entity-reference field--label-hidden field__items"]'
    ),
    css_topics = case_when(
      url_type == "blog" ~ NA,
      url_type == "press-release" ~ NA
    )
  )

filtered_iiss <- sitemap_viable_links(sitemaps, short.source = "iiss", url.filter = iiss_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), iiss_include[1], stringr::regex("/\\w"))) ~ iiss_include[1],
    ), css_text = ".reading",
    css_title = ".introduction",
    css_date = ".label--date",
    css_author = ".person__name",
    css_topics = NA
  )

filtered_third <- sitemap_viable_links(sitemaps, short.source = "third", url.filter = third_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[1], stringr::regex("/\\w"))) ~ third_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[2], stringr::regex("/\\w"))) ~ third_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[3], stringr::regex("/\\w"))) ~ third_include[3],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), third_include[4], stringr::regex("/\\w"))) ~ third_include[4]
    ), css_text = case_when(
      url_type == "memo" ~ ".Content",
      url_type == "report" ~ ".Content",
      url_type == "press" ~ ".col-lg-8",
      url_type == "blog" ~ ".Content"
    ),
    css_title = case_when(
      url_type == "memo" ~ "h1.mb-4",
      url_type == "report" ~ "h1.mb-4",
      url_type == "press" ~ "h1.mb-4",
      url_type == "blog" ~ "h1.mb-4"
    ),
    css_date = case_when(
      url_type == "memo" ~ ".published-at",
      url_type == "report" ~ ".published-at",
      url_type == "press" ~ ".published-at",
      url_type == "blog" ~ ".published-at"
    ),
    css_author = case_when(
      url_type == "memo" ~ ".title",
      url_type == "report" ~ ".title",
      url_type == "press" ~ ".title",
      url_type == "blog" ~ ".title"
    ),
    css_topics = case_when(
      url_type == "memo" ~ NA,
      url_type == "report" ~ NA,
      url_type == "press" ~ NA,
      url_type == "blog" ~ NA
    )
  )

filtered_fab <- sitemap_viable_links(sitemaps, short.source = "fab", url.filter = fab_exclude, exclude = TRUE) |>
  tidytable::mutate(
    url_type = "article",
    css_text = ".content",
    css_title = ".article-header-title",
    css_date = ".article-meta-block-date",
    css_author = ".article-people-author-content-heading",
    css_topics = NA
  )

filtered_cfr <- sitemap_viable_links(sitemaps, short.source = "cfr", url.filter = cfr_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cfr_include[1], stringr::regex("/\\w"))) ~ cfr_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cfr_include[2], stringr::regex("/\\w"))) ~ cfr_include[2]
    ), css_text = case_when(
      url_type == "article" ~ ".body-content",
      url_type == "in-brief" ~ ".body-content"
    ),
    css_title = case_when(
      url_type == "article" ~ ".article-header__title",
      url_type == "in-brief" ~ ".article-header__title"
    ),
    css_date = case_when(
      url_type == "article" ~ ".article-header__date-ttr",
      url_type == "in-brief" ~ ".article-header__date-ttr"
    ),
    css_author = case_when(
      url_type == "article" ~ ".article-header__link",
      url_type == "in-brief" ~ ".article-header__link"
    ),
    css_topics = case_when(
      url_type == "article" ~ NA,
      url_type == "in-brief" ~ NA
    )
  )

source(here::here("R", "write_to_db.R"))

write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 1L, loop_end = 5000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 5001L, loop_end = 10000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 10001L, loop_end = 15000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 15001L, loop_end = 20000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 20001L, loop_end = 25000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 25001L, loop_end = 30000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 30001L, loop_end = 35000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 35001L, loop_end = 40000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 40001L, loop_end = 45000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 45001L, loop_end = 50000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 50001L, loop_end = 55000L)
Sys.sleep(10)
write_to_db(filtered_aei, scrape_db, "text_aei", loop_start = 55001L)


# Disconnecting from DuckDB
DBI::dbDisconnect(scrape_db, shutdown = TRUE)
