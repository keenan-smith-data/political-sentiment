export_db <- function(file_location, con) {
  glue::glue_sql("
                 EXPORT DATABASE {file_location} (FORMAT PARQUET)",
                 .con = con
  )
}