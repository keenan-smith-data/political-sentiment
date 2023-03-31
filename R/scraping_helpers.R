element_pull <- function(e.html, css.tag) {
  e.html |>
    rvest::html_elements(css = css.tag) |>
    rvest::html_text2()
}

title_pull <- function(s.html, css.tag) {
  #  browser()
  title.text <- element_pull(s.html, css.tag)
  art_title <- title.text[[1]]
  return(art_title)
}

text_pull <- function(s.html, text.css = NA) {
  final.data <- s.html |>
    rvest::html_element(css = text.css) |>
    rvest::html_text2() |>
    tidytable::na_if("")
  final.data <- final.data |>
    tidytable::as_tidytable() |>
    tidytable::drop_na(x)
  return(final.data)
}

date_pull_testing <- function(s.html, date.css) {
  #  browser()
  trad.date.format <- stringr::regex("^(?:(1[0-2]|0?[1-9])/(3[01]|[12][0-9]|0?[1-9])|(3[01]|[12][0-9]|0?[1-9])/(1[0-2]|0?[1-9]))/(?:[0-9]{2})?[0-9]{2}$")
  yyyy.mm.dd <- stringr::regex("([0-9]{4})-?(1[0-2]|0[1-9])-?(3[01]|0[1-9]|[12][0-9])")
  month.dd.yyyy <- stringr::regex("(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?),?\\s+(\\d{1,2}),?\\s+(\\d{4})")
  yyyy <- stringr::regex("\\b\\d{4}\\b")

  date.text <- element_pull(e.html = s.html, css.tag = date.css)
  date.test <- tidytable::case_when(
    stringr::str_detect(date.text, trad.date.format) ~ stringr::str_extract(date.text, trad.date.format),
    stringr::str_detect(date.text, yyyy.mm.dd) ~ stringr::str_extract(date.text, yyyy.mm.dd),
    stringr::str_detect(date.text, month.dd.yyyy) ~ stringr::str_extract(date.text, month.dd.yyyy),
    stringr::str_detect(date.text, yyyy) ~ paste0("12-31-", stringr::str_extract(date.text, yyyy)),
    .default = as.character("1970-01-01")
  )
  art_date <- lubridate::mdy(date.test)
  art_date <- art_date[[1]]
  return(art_date)
}

date_pull_special <- function(s.html, date.css) {
  date.text <- rvest::html_elements(s.html, css = date.css)
  date.text <- xml2::xml_attrs(date.text[[1]])[1]
  date.text <- stringr::str_extract(date.text, stringr::regex("\\d\\d\\d\\d-\\d\\d-\\d\\d"))
  art_date <- lubridate::mdy(date.text)
  return(date.text)
}

date_pull <- function(s.html, date.css) {
  date.text <- element_pull(e.html = s.html, css.tag = date.css)
  date.text <- date.text[1]
  art_date <- lubridate::mdy(date.text)
  return(art_date)
}

author_pull <- function(s.html, author.css, art.source) {
  if (length(author.css) > 1) {
    art.authors <- tidytable::map_chr(.x = author.css, element_pull, e.html = s.html)
    art_author <- paste(art.authors, collapse = ",")
  } else if (length(author.css) == 1) {
    art.author <- element_pull(s.html, author.css)
    art_author <- paste(art.author, collapse = ", ")
  } else {
    art_author <- art.source
  }
  return(art_author)
}

topic_pull <- function(s.html, topic.css = NA) {
  if (is.na(topic.css)) {
    art_topic <- NA
  } else {
    art.topic <- element_pull(s.html, topic.css)
    if (length(art.topic) > 1) {
      art_topic <- paste(art.topic, collapse = ", ")
    } else if (length(art.topic) == 1) {
      art_topic <- art.topic
    } else {
      art_topic <- NA
    }
  }
  return(art_topic)
}