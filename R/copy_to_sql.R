copy_to_table <- function(tbl_name, file_location, con) {
  glue::glue_sql("
                 COPY {tbl_name} TO {file_location} (FORMAT 'parquet')",
                 .con = con
  )
}
