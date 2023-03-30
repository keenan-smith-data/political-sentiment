element_pull <- function(e.html, css.tag) {
  e.html |>
    rvest::html_elements(css = css.tag) |>
    rvest::html_text2()
}

text_pull <- function(s.html, text.css = NA) {
  final.data <- s.html |>
    rvest::html_element(css = text.css) |>
    rvest::html_elements("p") |>
    rvest::html_text2() |>
    tidytable::na_if("")
  if (all(is.na(final.data))) {
    final.data <- s.html |>
      rvest::html_element(css = text.css) |>
      rvest::html_elements("div") |>
      rvest::html_text2() |>
      tidytable::na_if("")
  } 
  final.data <- final.data |>
    tidytable::as_tidytable() |>
    tidytable::drop_na(x)
  return(final.data)
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
  } else if (length(author.css)  == 1) {
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

article_pull_df <- function(df) {
  hyperlink <- df$url[[1]]
  title.css.tag <- df$css_title[[1]]
  text.css.tag <- df$css_text[[1]]
  date.css.tag <- df$css_date[[1]]
  author.css.tags <- df$css_author[[1]]
  art.source <- df$art_source[[1]]
  topic.css.tags <- df$css_topics[[1]]
  rm(df)
  
  source.html <- xml2::read_html(hyperlink)
  art_title <- element_pull(e.html = source.html,
                            css.tag = title.css.tag)
  art_text <- text_pull(s.html = source.html,
                        text.css = text.css.tag)
  art_date <- date_pull(s.html = source.html,
                        date.css = date.css.tag)
  art_author <- author_pull(s.html = source.html,
                            author.css = author.css.tags,
                            art.source = art.source)
  art_topic <- topic_pull(s.html = source.html,
                          topic.css = topic.css.tags)
  final.data <- art_text |>
    tidytable::rename(text = x) |>
    tidytable::mutate(
      art_link = hyperlink,
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_source = art.source
    )
  return(final.data)
}