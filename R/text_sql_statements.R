create_art_table <- function(tbl_name, con) {
  glue::glue_sql("
                 CREATE OR REPLACE TABLE {tbl_name} (
                 art_link VARCHAR PRIMARY KEY,
                 art_date DATE,
                 art_author VARCHAR,
                 art_title VARCHAR,
                 art_source VARCHAR,
                 full_text VARCHAR,
                 pull_index INTEGER
                 )",
                 .con = con
  )
}

insert_into_art_table <- function(df, tbl_name, con) {
  glue::glue_sql("
                 INSERT OR IGNORE INTO {tbl_name} (art_link, art_date, art_author, art_title, art_source, full_text, pull_index)
                 VALUES ({df$art_link}, {df$art_date}, {df$art_author}, {df$art_title}, {df$art_source}, {df$full_text}, {df$pull_index})
                 ",
                 .con = con)
}