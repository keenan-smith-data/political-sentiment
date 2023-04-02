write_to_db <- function(df, db.con, table.title) {
  #  browser()
  table_create <- create_art_table(table.title, db.con)
  DBI::dbExecute(db.con, table_create)
  n_rows <- length(df$url)
  iteration_df <- tibble::tibble()
  
  Sys.time()
  for (i in seq_along(df$url)) {
    Sys.sleep(1)
    tryCatch(
      {
        iteration_df <- R.utils::withTimeout(
          {
            article_pull_try_html(df[i])
          },
          timeout = 30
        )
      },
      error = function(e) {
        message(e)
        message("\nCaught and Continue\n")
      },
      warning = function(w) {
        message(w)
        message("\nCaught and Continue\n")
      },
      TimeoutException = function(te) {
        message("\nTimeout. Skipping\n")
        tibble::tibble(
          art_link = df$url, art_date = lubridate::date("1970-01-01"),
          art_author = "timeout error", art_title = "timeout error", art_source = df$art_source,
          full_text = "timeout error"
        )
      }
    )
    iteration_df$pull_index <- i
    table_insert <- insert_into_art_table(iteration_df, table.title, db.con)
    tryCatch(
      {
        message(paste("\nWriting to DB", i))
        DBI::dbExecute(db.con, table_insert)
      },
      error = function(e) {
        message(e)
      },
      warning = function(w) {
        message(w)
      }, finally = {
        message("\nContinuing to Next URL\n")
        message(paste0("\n", round((i / n_rows * 100), digits = 2), "% complete"))
      }
    )
  }
  Sys.time()
}
