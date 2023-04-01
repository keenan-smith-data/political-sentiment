here::i_am("R/viable_links_original.R")

# Connecting to DuckDB
pol_sent_db <- DBI::dbConnect(duckdb::duckdb(), dbdir = here::here("data", "political-sentiment.duckdb"))
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
am_include <- c("salvo", "features", "memo")
cap_include <- c("article")
cato_include <- c("blog", "commentary")
cbpp_include <- c("blog", "research", "press/statements", "press/press-releases")
comf_include <- c("blog", "publications")
disc_include <- c("a")
epi_include <- c("blog")

epic_filter <- initial_look(sitemaps, "epic") |>
  path_examination() |>
  tidytable::filter(n > 1)

epic_exclude <- epic_filter[[1]][-1]
rm(epic_filter)

gutt_include <- c("news-release")
heritage_include <- c("commentary", "report")
hrw_include <- c("news", "report", "world-report")
mani_include <- c("html")
merc_include <- c("expert-commentary")
osf_include <- c("voices")
tnat_include <- c("article")
urban_include <- c("urban-wire")

# Viable Links
filtered_aei <- sitemap_viable_links(sitemaps, short.source = "aei", url.filter = aei_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[1], stringr::regex("/\\w"))) ~ aei_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[2], stringr::regex("/\\w"))) ~ aei_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), aei_include[3], stringr::regex("/\\w"))) ~ aei_include[3]
    ),
    css_title = ".entry-title",
    css_date = "p.date",
    css_topics = ".p-3",
    css_author = "p.author",
    css_text = ".entry-content"
  )

filtered_am <- sitemap_viable_links(sitemaps, short.source = "am", url.filter = am_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[1], stringr::regex("/\\w"))) ~ am_include[1],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[2], stringr::regex("/\\w"))) ~ am_include[2],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[3], stringr::regex("/\\w"))) ~ am_include[3],
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), am_include[4], stringr::regex("/\\w"))) ~ am_include[4]
    ),
    css_title = ".tam__single-header-title",
    css_date = ".tam__single-header-meta-date",
    css_topics = ".tam__single-content-tags",
    css_author = ".tam__single-header-author",
    css_text = ".tam__single-content-output"
  )

filtered_cap <- sitemap_viable_links(sitemaps, short.source = "cap", url.filter = cap_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), cap_include[1], stringr::regex("/\\w"))) ~ cap_include[1]
    ),
    css_text = '[class="wysiwyg -xw:4 -mx:a"]',
    css_title = ".header2-title",
    css_date = '[class="-t:9 -tt:u -c:d2t"]',
    css_author = '[class="authors1-list -as:2 -t:10"]',
    css_topics = '[class="-c:a5t term_link_listing"]'
  )

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

filtered_disc <- sitemap_viable_links(sitemaps, short.source = "disc", url.filter = disc_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), disc_include[1], stringr::regex("/\\w"))) ~ disc_include[1]
    ), css_text = ".article-center",
    css_title = ".article-title",
    css_date = ".article-date",
    css_author = ".article-author",
    css_topics = ".article-categories"
  )

filtered_epi <- sitemap_viable_links(linkchecker, short.source = "epi", url.filter = epi_include) |>
  tidytable::filter(
    size > 1,
    stringr::str_detect(url, "wp-json|page|wp-content|/feed/", negate = TRUE)
  ) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), epi_include[1], stringr::regex("/\\w"))) ~ epi_include[1],
    ), css_text = ".blog-the_content",
    css_title = "h2",
    css_date = ".blog-byline",
    css_author = ".loop-author",
    css_topics = ".blog-tags"
  )

filtered_epic <- sitemap_viable_links(sitemaps, short.source = "epic", url.filter = epic_exclude, exclude = TRUE) |>
  tidytable::mutate(url_type = "article")

filtered_gutt <- sitemap_viable_links(sitemaps, short.source = "gutt", url.filter = gutt_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), gutt_include[1], stringr::regex("/\\w"))) ~ gutt_include[1]
    ), css_text = ".c-content",
    css_title = ".c-page-title--article-title",
    css_date = ".c-metadata-tag--solid-black",
    css_author = ".fn",
    css_topics = ".field__item"
  )

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

filtered_mani <- sitemap_viable_links(sitemaps, short.source = "mani", url.filter = mani_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), mani_include[1], stringr::regex("/\\w"))) ~ mani_include[1]
    ), css_text = ".l_ipage-content",
    css_title = "h1.title",
    css_date = ".date",
    css_author = ".authors",
    css_topics = ".topics"
  )

filtered_merc <- sitemap_viable_links(sitemaps, short.source = "merc", url.filter = merc_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), merc_include[1], stringr::regex("/\\w"))) ~ merc_include[1]
    ), css_text = ".coh-ce-cpt_text-ec73cf93",
    css_title = "h1.coh-heading",
    css_date = "[datetime]",
    css_author = ".coh-style-byline",
    css_topics = '[data-item="category"]'
  )

filtered_osf <- sitemap_viable_links(linkchecker, short.source = "osf", url.filter = osf_include) |>
  tidytable::filter(size > 1) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("org/"), osf_include[1], stringr::regex("/\\w"))) ~ osf_include[1],
    ), css_text = ".m-textBlock",
    css_title = "h1",
    css_date = ".m-articleMetaBar__body",
    css_author = ".a-articleAuthor__title",
    css_topics = ".a-articleMetaItem__body"
  ) |>
  tidytable::drop_na()

filtered_tnat <- sitemap_viable_links(linkchecker, short.source = "tnat", url.filter = tnat_include) |>
  tidytable::mutate(url_type = tidytable::case_when(
    stringr::str_detect(url, paste0(stringr::regex("\\w/"), tnat_include[1], stringr::regex("/\\w"))) ~ tnat_include[1],
  ))

filtered_urban <- sitemap_viable_links(sitemaps, short.source = "urban", url.filter = urban_include) |>
  tidytable::mutate(
    url_type = tidytable::case_when(
      stringr::str_detect(url, paste0(stringr::regex("\\w/"), urban_include[1], stringr::regex("/\\w"))) ~ urban_include[1]
    ), css_text = '[data-block-plugin-id="urban-blocks-body-or-summary"]',
    css_title = '[element="h1"]',
    css_date = ".date",
    css_author = ".mb-2",
    css_topics = '[class="inline-block mr-4 mb-4"]'
  )

# Disconnecting from DuckDB
DBI::dbDisconnect(pol_sent_db, shutdown = TRUE)

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