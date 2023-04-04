write_to_db_js <- function(df, db.con, table.title, remDr, loop_start = 1L, loop_end = nrow(df)) {
  source(here::here("R", "text_sql_statements.R"))
  source(here::here("R", "scraping_helpers.R"))
  source(here::here("R", "article_pull_js.R"))
  n_rows <- as.integer(nrow(df))
  loop_end <- as.integer(loop_end)
  start_time <- proc.time()
  iteration_df <- tibble::tibble()
  Sys.time()
  for (i in loop_start:loop_end) {
    Sys.sleep(1)
    tryCatch(
      {
        iteration_df <- R.utils::withTimeout(
          {
            article_pull_try_js(df[i], remDr = remDr)
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
        message("\nData Written Successfully to DB\n")
      },
      error = function(e) {
        message(e)
      },
      warning = function(w) {
        message(w)
      }, finally = {
        message("\nContinuing to Next URL\n")
        message(paste0("\n", round((i / n_rows * 100), digits = 2), "% complete"))
        print(proc.time() - start_time)
      }
    )
  }
  Sys.time()
}
