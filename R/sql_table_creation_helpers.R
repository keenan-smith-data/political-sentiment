create_linkchecker_table <- function(tbl_name, con) {
  glue::glue_sql("
                 CREATE TABLE {tbl_name} (
                 rowid INTEGER,
                 url VARCHAR,
                 size INTEGER,
                 result VARCHAR,
                 art_source VARCHAR,
                 )
                 ",
    .con = con
  )
}

create_sitemap_table <- function(tbl_name, con) {
  glue::glue_sql("
                 CREATE TABLE {tbl_name} (
                 rowid INTEGER,
                 url VARCHAR,
                 lastmod TIMESTAMP,
                 art_source VARCHAR,
                 )
                 ",
    .con = con
  )
}

create_source_table <- function(tbl_name, con) {
  glue::glue_sql("
                 CREATE TABLE {tbl_name} (
                 art_source VARCHAR PRIMARY KEY,
                 short_source VARCHAR,
                 source_bias VARCHAR,
                 )
                 ",
    .con = con
  )
}

copy_table <- function(tbl_name, file_location, con) {
  glue::glue_sql("
                 COPY {tbl_name} FROM {file_location} ( HEADER )
                 ",
    .con = con
  )
}

copy_to_table <- function(tbl_name, file_location, con) {
  glue::glue_sql("
                 COPY {tbl_name} TO {file_location} (FORMAT 'parquet')
                 ",
                 .con = con
  )
}

copy_from_table <- function(tbl_name, file_location, con) {
  glue::glue_sql("
                 COPY {tbl_name} FROM {file_location} (FORMAT 'parquet')
                 ",
                 .con = con
  )
}