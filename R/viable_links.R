here::i_am("R/viable_links.R")
library(here)
library(DBI)
library(duckdb)
library(tidytable)
# Connecting to DuckDB
pol_sent_db <- dbConnect(duckdb::duckdb(), dbdir = here("data", "political-sentiment.duckdb"))
# Loading Lazy DB for dbplyr
sitemaps <- dplyr::tbl(pol_sent_db, "sitemap_data")
linkchecker <- dplyr::tbl(pol_sent_db, "linkchecker_data")
source_table <- dplyr::tbl(pol_sent_db, "source_table")
# Function Block for Obtaining Viable Links
sitemap_viable_links <- function(df,
                                 short.source = NULL,
                                 art.source = NULL,
                                 url.filter,
                                 exclude = FALSE) {
  # Defining OR statement here since DBplyr doesn't like it
  url.filter <- stringr::str_c(stringr::regex("\\w/"),
    url.filter,
    stringr::regex("/\\w"),
    collapse = "|"
  )
  # Checking if art.source exists
  if (is.null(art.source)) {
    # Checking if strings are inclusion or exclusion
    if (exclude == FALSE) {
      # Inclusion
      df |>
        dplyr::left_join(source_table, by = source_table$art_source) |>
        dplyr::filter(
          short_source == short.source,
          stringr::str_detect(url, url.filter),
          stringr::str_detect(url, "page=", negate = TRUE)
        ) |>
        dplyr::collect() |>
        tidytable::distinct(url, .keep_all = TRUE)
    } else {
      # Exclusion
      df |>
        dplyr::left_join(source_table, by = source_table$art_source) |>
        dplyr::filter(
          short_source == short.source,
          stringr::str_detect(url, url.filter, negate = TRUE)
        ) |>
        dplyr::collect() |>
        tidytable::distinct(url, .keep_all = TRUE)
    }
    # If short.source is not used
  } else if (is.null(short.source)) {
    df |>
      dplyr::filter(
        art_source == art.source,
        stringr::str_detect(url, url.filter),
        stringr::str_detect(url, "page=", negate = TRUE)
      ) |>
      dplyr::collect() |>
      tidytable::distinct(url, .keep_all = TRUE)
  }
}

initial_helper <- function(.df, short.source = NULL, art.source = NULL) {
  if (is.null(art.source)) {
    .df |>
      dplyr::left_join(source_table, by = source_table$art_source) |>
      dplyr::filter(short_source == short.source) |>
      dplyr::collect()
  } else if (is.null(short.source)) {
    .df |>
      dplyr::filter(art_source == art.source) |>
      dplyr::collect()
  }
}

initial_look <- function(.df, short.source) {
  temp <- initial_helper(.df, short.source)
  urls <- tidytable::map_df(.x = temp$url, .f = xml2::url_parse)
  return(urls)
}

path_examination <- function(.df) {
  .df |>
    tidytable::separate_wider_delim(path, "/") |>
    tidytable::group_by(path2) |>
    tidytable::count(sort = T)
}
# Inclusion and Exclusion Vectors
aei_include <- c("articles", "carpe-diem", "op-eds")
cato_include <- c("blog", "commentary")
hrw_include <- c("news", "report", "world-report")
heritage_include <- c("commentary", "report")
cap_include <- c("article")
urban_include <- c("research")
merc_include <- c("economic-insights", "research")
mani_include <- c("html")
cbpp_include <- c("blog", "research", "press")
am_include <- c("salvo", "features", "memo", "feature")
disc_include <- c("a")

epic_filter <- initial_look(sitemaps, "epic") |>
  path_examination() |>
  filter(n > 1)

epic_exclude <- epic_filter[[1]][-1]
rm(epic_filter)

gutt_include <- c("journals", "article", "news-release", "report")
comf_include <- c("blog", "publications", "feed")
epi_include <- c("blog")
osf_include <- c("voices", "publications")
tnat_include <- c("article")

# Viable Links
filtered_aei <- sitemap_viable_links(sitemaps, short.source = "aei", url.filter = aei_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[1], stringr::regex("/\\w"))) ~ aei_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[2], stringr::regex("/\\w"))) ~ aei_include[2],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[3], stringr::regex("/\\w"))) ~ aei_include[3]
    ))

filtered_cato <- sitemap_viable_links(sitemaps, short.source = "cato", url.filter = cato_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), cato_include[1], stringr::regex("/\\w"))) ~ cato_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), cato_include[2], stringr::regex("/\\w"))) ~ heritage_include[2]
  ))

filtered_hrw <- sitemap_viable_links(sitemaps, short.source = "hrw", url.filter = hrw_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), hrw_include[1], stringr::regex("/\\w"))) ~ hrw_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), hrw_include[2], stringr::regex("/\\w"))) ~ hrw_include[2],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), hrw_include[3], stringr::regex("/\\w"))) ~ hrw_include[3]
  ))

filtered_heritage <- sitemap_viable_links(sitemaps, short.source = "heritage", url.filter = heritage_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), heritage_include[1], stringr::regex("/\\w"))) ~ heritage_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), heritage_include[2], stringr::regex("/\\w"))) ~ heritage_include[2]
  ))

filtered_cap <- sitemap_viable_links(sitemaps, short.source = "cap", url.filter = cap_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), cap_include[1], stringr::regex("/\\w"))) ~ cap_include[1]
  ))

filtered_urban <- sitemap_viable_links(sitemaps, short.source = "urban", url.filter = urban_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), urban_include[1], stringr::regex("/\\w"))) ~ urban_include[1]
  ))

filtered_merc <- sitemap_viable_links(sitemaps, short.source = "merc", url.filter = merc_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), merc_include[1], stringr::regex("/\\w"))) ~ merc_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), merc_include[2], stringr::regex("/\\w"))) ~ merc_include[2]
  ))

filtered_mani <- sitemap_viable_links(sitemaps, short.source = "mani", url.filter = mani_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), mani_include[1], stringr::regex("/\\w"))) ~ mani_include[1]
  ))

filtered_cbpp <- sitemap_viable_links(sitemaps, short.source = "cbpp", url.filter = cbpp_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[1], stringr::regex("/\\w"))) ~ cbpp_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[2], stringr::regex("/\\w"))) ~ cbpp_include[2],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), cbpp_include[3], stringr::regex("/\\w"))) ~ cbpp_include[3]
  ))

filtered_am <- sitemap_viable_links(sitemaps, short.source = "am", url.filter = am_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[1], stringr::regex("/\\w"))) ~ am_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[2], stringr::regex("/\\w"))) ~ am_include[2],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[3], stringr::regex("/\\w"))) ~ am_include[3],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[4], stringr::regex("/\\w"))) ~ am_include[4]
  ))

filtered_disc <- sitemap_viable_links(sitemaps, short.source = "disc", url.filter = disc_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), disc_include[1], stringr::regex("/\\w"))) ~ disc_include[1]
  ))

filtered_epic <- sitemap_viable_links(sitemaps, short.source = "epic", url.filter = epic_exclude, exclude = TRUE)

filtered_gutt <- sitemap_viable_links(sitemaps, short.source = "gutt", url.filter = gutt_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), gutt_include[1], stringr::regex("/\\w"))) ~ gutt_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), gutt_include[2], stringr::regex("/\\w"))) ~ gutt_include[2],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), gutt_include[3], stringr::regex("/\\w"))) ~ gutt_include[3],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), gutt_include[4], stringr::regex("/\\w"))) ~ gutt_include[4]
  ))

filtered_comf <- sitemap_viable_links(linkchecker, short.source = "comf", url.filter = comf_include) |>
  filter(size > 1) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), comf_include[1], stringr::regex("/\\w"))) ~ comf_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), comf_include[2], stringr::regex("/\\w"))) ~ comf_include[2],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), comf_include[3], stringr::regex("/\\w"))) ~ comf_include[3]
  ))

filtered_epi <- sitemap_viable_links(linkchecker, short.source = "epi", url.filter = epi_include) |>
  filter(size > 1) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), epi_include[1], stringr::regex("/\\w"))) ~ epi_include[1]
  ))

filtered_osf <- sitemap_viable_links(linkchecker, short.source = "osf", url.filter = osf_include) |>
  filter(size > 1) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), osf_include[1], stringr::regex("/\\w"))) ~ osf_include[1],
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), osf_include[2], stringr::regex("/\\w"))) ~ osf_include[2]
  ))

filtered_tnat <- sitemap_viable_links(linkchecker, short.source = "tnat", url.filter = tnat_include) |>
  mutate(url_type = case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), tnat_include[1], stringr::regex("/\\w"))) ~ tnat_include[1],
  ))

# Disconnecting from DuckDB
dbDisconnect(pol_sent_db, shutdown = TRUE)

rm(
  pol_sent_db,
  sitemaps,
  linkchecker,
  source_table,
  sitemap_viable_links,
  initial_helper,
  initial_look,
  path_examination,
  aei_include,
  cato_include,
  hrw_include,
  heritage_include,
  cap_include,
  urban_include,
  merc_include,
  mani_include,
  cbpp_include,
  am_include,
  disc_include,
  epic_exclude,
  gutt_include,
  comf_include,
  epi_include,
  osf_include,
  tnat_include
)

detach(package:duckdb, unload = TRUE)