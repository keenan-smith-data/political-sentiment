article_pull_html <- function(df) {
  # browser()
  hyperlink <- df$url[[1]]
  title.css.tag <- df$css_title[[1]]
  text.css.tag <- df$css_text[[1]]
  date.css.tag <- df$css_date[[1]]
  author.css.tags <- df$css_author[[1]]
  art.source <- df$art_source[[1]]
  topic.css.tags <- df$css_topics[[1]]

# source.html <- polite::bow(hyperlink) |> polite::scrape(verbose = TRUE)
  source.html <- xml2::read_html(hyperlink)
  art_title <- title_pull(
    s.html = source.html,
    css.tag = title.css.tag
  )
  art_text <- text_pull(
    s.html = source.html,
    text.css = text.css.tag
  )
  art_date <- date_pull(
    s.html = source.html,
    date.css = date.css.tag
  )
  art_author <- author_pull(
    s.html = source.html,
    author.css = author.css.tags,
    art.source = art.source
  )
  art_topic <- topic_pull(
    s.html = source.html,
    topic.css = topic.css.tags
  )
  final.data <- art_text |>
    tidytable::rename(text = x) |>
    tidytable::mutate(
      art_link = hyperlink,
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_source = art.source
    ) |>
    tidytable::group_by(art_link, art_date, art_author, art_topic, art_title, art_source) |> # These are the metadata tags REFACTOR in future
    tidytable::summarise(
      full_text = paste(text, collapse = " "),
      .groups = "drop"
    )

  return(final.data)
}

article_pull_try_html <- function(df) {
  tryCatch(
    expr = {
      message(paste("\nTrying", df$url))
      article_pull_html(df)
    },
    error = function(cond) {
      message(paste("\nThis URL has caused an error:\n", df$url))
      message(cond)
      tibble::tibble(
        art_link = df$url, art_date = lubridate::date("1970-01-01"),
        art_author = "error", art_title = "error", art_source = df$art_source,
        full_text = "error"
      )
    },
    warning = function(cond) {
      message(paste("\nURL has a warning:\n", df$url))
      message(cond)
      tibble::tibble(
        art_link = df$url, art_date = lubridate::date("1970-01-01"),
        art_author = character(), art_title = character(), art_source = character(),
        full_text = character()
      )
    }, finally = {
      message(paste("\nProcessed URL:\n", df$url))
    }
  )
}
