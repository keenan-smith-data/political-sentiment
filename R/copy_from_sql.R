copy_from_table <- function(tbl_name, file_location, con) {
  glue::glue_sql("
                 COPY {tbl_name} FROM {file_location} (FORMAT 'parquet')",
                 .con = con
  )
}