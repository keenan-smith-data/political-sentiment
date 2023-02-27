# Function for Splitting large datasets
data_split <- function(data, n_groups = 10) {
  temp <- data
  temp$group <- 1:nrow(temp) %% n_groups + 1
  temp_list <- split(temp, temp$group)
  return(temp_list)
}

# Jacobin Article Pull
jacobin_pull <- function(hyperlink) {
  temp <- xml2::read_html(hyperlink)
  art_link <- hyperlink
  art_title <-
    temp |>
    rvest::html_elements(css = ".po-hr-cn__title") |>
    rvest::html_text2()
  art_author <-
    temp |>
    rvest::html_elements(css = ".po-hr-cn__author-link") |>
    rvest::html_text2()
  if (length(art_author) > 1) {
    art_author <- paste(art_author, collapse = ", ")
  } else if (length(art_author) == 1) {
    art_author <- art_author
  } else {
    art_author <- "Jacobin"
  }
  art_topic <-
    temp |>
    rvest::html_elements(css = ".po-hr-fl__taxonomy") |>
    rvest::html_text2()
  if (length(art_topic) > 1) {
    art_topic <- paste(art_topic, collapse = ", ")
  } else if (length(art_topic) == 1) {
    art_topic <- art_topic
  } else {
    art_topic <- NA
  }
  art_date <-
    temp |>
    rvest::html_elements(css = ".po-hr-fl__date") |>
    rvest::html_text2() |>
    stringr::str_replace("\\.", "/") |>
    lubridate::mdy()
  text_data <-
    temp |>
    rvest::html_element(css = "#post-content") |>
    rvest::html_nodes("p") |>
    rvest::html_text2() |>
    dplyr::as_tibble() |>
    dplyr::rename(text = value) |>
    dplyr::mutate(
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_link = art_link,
      art_source = "Jacobin"
    )
  rm(temp)
  scrape_check(text_data)
  return(text_data)
}

jacobin_pull_tests <- function(hyperlink) {
  session <- read_html(hyperlink)
  return(session)
}

j_pull_try <- function(hyperlink) {
  tryCatch(
    expr = {
      message(paste("Trying", hyperlink))
      jacobin_pull(hyperlink)
    },
    error = function(cond) {
      message(paste("This URL has caused an error:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    warning = function(cond) {
      message(paste("URL has a warning:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    finally = {
      message(paste("\nProcessed URL:", hyperlink))
      #      Sys.sleep(5)
    }
  )
}

# Heritage Article Pull
heritage_com_pull <- function(hyperlink) {
  date_formats <- "[:alpha:]+ [:graph:]+ [:digit:]+"
  authors <- c(".author-card__name", "author-card__multi-name")
  temp <- xml2::read_html(hyperlink)
  art_link <- hyperlink
  art_title <-
    temp |>
    rvest::html_elements(css = ".commentary__headline") |>
    rvest::html_text2()
  art_author_1 <-
    temp |>
    rvest::html_nodes(".author-card__name") |>
    rvest::html_text2()
  art_author_2 <-
    temp |>
    rvest::html_nodes(".author-card__multi-name") |>
    rvest::html_text2()
  art_author <- c(art_author_1, art_author_2)
  if (length(art_author) > 1) {
    art_author <- paste(art_author, collapse = ", ")
  } else if (length(art_author) == 1) {
    art_author <- art_author
  } else {
    art_author <- "Heritage Foundation"
  }
  temp_topic <- hyperlink |>
    stringr::str_split("/") |>
    as_vector()
  art_topic <- temp_topic[[4]]
  art_date <-
    temp |>
    rvest::html_elements(css = ".article-general-info") |>
    rvest::html_text2() |>
    stringr::str_extract(date_formats) |>
    lubridate::mdy()
  text_data <-
    temp |>
    rvest::html_nodes(".article__body-copy") |>
    rvest::html_nodes("p") |>
    rvest::html_text2() |>
    dplyr::as_tibble() |>
    dplyr::rename(text = value) |>
    dplyr::mutate(
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_link = art_link,
      art_source = "Heritage Commentary"
    )
  rm(temp)
  scrape_check(text_data)
  return(text_data)
}

heritage_pull_test <- function(hyperlink) {
  authors <- c(".author-card__name", ".author-card__multi-name")
  temp <- xml2::read_html(hyperlink)
  art_author_1 <-
    temp |>
    rvest::html_nodes(".author-card__name") |>
    rvest::html_text2()
  art_author_2 <-
    temp |>
    rvest::html_nodes(".author-card__multi-name") |>
    rvest::html_text2()
  art_author <- c(art_author_1, art_author_2)
  if (length(art_author) > 1) {
    art_author <- paste(art_author, collapse = ", ")
  } else if (length(art_author) == 1) {
    art_author <- art_author
  } else {
    art_author <- NA
  }
  return(art_author)
}

h_com_pull_try <- function(hyperlink) {
  tryCatch(
    expr = {
      message(paste("Trying", hyperlink))
      heritage_com_pull(hyperlink)
    },
    error = function(cond) {
      message(paste("This URL has caused an error:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    warning = function(cond) {
      message(paste("URL has a warning:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    finally = {
      message(paste("\nProcessed URL:", hyperlink))
      #      Sys.sleep(5)
    }
  )
}

# Heritage Article Pull
heritage_rep_pull <- function(hyperlink) {
  date_formats <- "[:alpha:]+ [:graph:]+ [:digit:]+"
  temp <- xml2::read_html(hyperlink)
  art_link <- hyperlink
  art_title <-
    temp |>
    rvest::html_elements(css = ".headline") |>
    rvest::html_text2()
  art_author_1 <-
    temp |>
    rvest::html_nodes(".contributor-card") |>
    rvest::html_text2() |>
    str_remove("Authors: ")
  art_author_2 <-
    temp |>
    rvest::html_nodes(".expert-card__expert-name") |>
    rvest::html_text2()
  art_author <- c(art_author_1, art_author_2)
  if (length(art_author) > 1) {
    art_author <- paste(art_author, collapse = ", ")
  } else if (length(art_author) == 1) {
    art_author <- art_author
  } else {
    art_author <- "Heritage Foundation"
  }
  temp_topic <- hyperlink |>
    stringr::str_split("/") |>
    as_vector()
  art_topic <- temp_topic[[4]]
  art_date <-
    temp |>
    rvest::html_elements(css = ".article-general-info") |>
    rvest::html_text2() |>
    stringr::str_extract(date_formats) |>
    lubridate::mdy()
  text_data <-
    temp |>
    rvest::html_nodes(".article__body-copy") |>
    rvest::html_nodes("p") |>
    rvest::html_text2() |>
    dplyr::as_tibble() |>
    dplyr::rename(text = value) |>
    dplyr::mutate(
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_link = art_link,
      art_source = "Heritage Report"
    )
  rm(temp)
  scrape_check(text_data)
  return(text_data)
}

h_rep_tests <- function(hyperlink) {
  temp <- xml2::read_html(hyperlink)
  art_author_1 <-
    temp |>
    rvest::html_nodes(".contributor-card") |>
    rvest::html_text2() |>
    str_remove("Authors: ")
  art_author_2 <-
    temp |>
    rvest::html_nodes(".expert-card__expert-name") |>
    rvest::html_text2()
  art_author <- c(art_author_1, art_author_2)
  if (length(art_author) > 1) {
    art_author <- paste(art_author, collapse = ", ")
  } else if (length(art_author) == 1) {
    art_author <- art_author
  } else {
    art_author <- "Heritage Foundation"
  }
  return(art_author)
}

h_rep_pull_try <- function(hyperlink) {
  tryCatch(
    expr = {
      message(paste("Trying", hyperlink))
      heritage_rep_pull(hyperlink)
    },
    error = function(cond) {
      message(paste("This URL has caused an error:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    warning = function(cond) {
      message(paste("URL has a warning:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    finally = {
      message(paste("\nProcessed URL:", hyperlink))
      #      Sys.sleep(5)
    }
  )
}

# Brookings Article Pull
brookings_pull <- function(hyperlink) {
  temp <- xml2::read_html(hyperlink)
  art_link <- hyperlink
  art_title <-
    temp |>
    rvest::html_elements(css = ".page-content .report-title") |>
    rvest::html_text2()
  art_author <-
    temp |>
    rvest::html_elements(css = ".names") |>
    rvest::html_text2()
  if (length(art_author) > 1) {
    art_author <- paste(art_author, collapse = ", ")
  } else if (length(art_author) == 1) {
    art_author <- art_author
  } else {
    art_author <- "Brookings Institute"
  }
  art_topic <-
    temp |>
    rvest::html_elements(css = ".series-header") |>
    rvest::html_text2()
  if (length(art_topic) > 1) {
    art_topic <- art_topic[[2]]
  } else if (length(art_topic) == 1) {
    art_topic <- art_topic
  } else {
    temp_topic <- hyperlink |>
      stringr::str_split("/") |>
      as_vector()
    art_topic <- temp_topic[[5]]
  }
  art_date <-
    temp |>
    rvest::html_elements("time[content]") |>
    rvest::html_text2() |>
    lubridate::mdy()
  text_data <-
    temp |>
    rvest::html_element(css = ".post-body") |>
    rvest::html_nodes("p") |>
    rvest::html_text2() |>
    dplyr::as_tibble() |>
    dplyr::rename(text = value) |>
    dplyr::mutate(
      art_title = art_title,
      art_author = art_author,
      art_date = art_date,
      art_topic = art_topic,
      art_link = art_link,
      art_source = "Brookings Institute"
    )
  rm(temp)
  scrape_check(text_data)
  return(text_data)
}

b_pull_tests <- function(hyperlink) {
  #  temp <- rvest::read_html(hyperlink)
  art_link <- hyperlink
  temp_topic <- hyperlink |>
    stringr::str_split("/") |>
    as_vector()
  art_topic <- temp_topic[[5]]
  return(art_topic)
}

b_pull_try <- function(hyperlink) {
  tryCatch(
    expr = {
      message(paste("Trying", hyperlink))
      brookings_pull(hyperlink)
    },
    error = function(cond) {
      message(paste("This URL has caused an error:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    warning = function(cond) {
      message(paste("URL has a warning:", hyperlink))
      message(cond)
      tibble::tibble(
        text = character(), art_title = character(), art_author = character(),
        art_date = lubridate::date("1970-01-01"), art_link = character()
      )
    },
    finally = {
      message(paste("\nProcessed URL:", hyperlink))
      #      Sys.sleep(5)
    }
  )
}
