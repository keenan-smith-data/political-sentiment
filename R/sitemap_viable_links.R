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