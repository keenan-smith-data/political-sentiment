article_pull <- function(hyperlink,
                         title.css.tag,
                         text.css.tag = NA,
                         date.css.tag,
                         author.css.tags,
                         topic.css.tags,
                         art.source) {
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
  final_data <- art_text |>
    tidytable::rename(text = x) |>
    tidytable::mutate(
      art_link = hyperlink,
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_source = art.source
    )
  return(final_data)
}