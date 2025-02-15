library(DBI)
library(odbc)
library(glue)


setwd('<working directory>')




# Connecting to Database
db_connection <- DBI::dbConnect(odbc::odbc(),
                                Driver="SnowflakeDSIIDriver",
                                Server="",
                                UID="",
                                PWD="",
                                ROLE = "SYSADMIN",
                                Database="<db_name>",
                                SCHEMA="<schema_name>",
                                WAREHOUSE="<warehouse>"
)







bulk_upload_to_snowflake <- function(con, filepath, schema, table_name, stage_name = "r_stage") {
  
  
  filepath_stage = gsub('\\\\', '/',filepath)
  
  putstring = glue("PUT 'file://{filepath_stage}' @{stage_name} auto_compress=true;")
  
  
  # Upload to Snowflake stage
  dbExecute(con, putstring)
  
  # Step 1: Infer the schema
  schema_info <- dbGetQuery(con, glue("
  SELECT COLUMN_NAME, TYPE
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION => '@{stage_name}/{basename(filepath)}',
      FILE_FORMAT => '{schema}.r_file_format'
      )
    )
  "))
  
  # Step 2: Convert column names to uppercase for case-insensitivity
  schema_info$COLUMN_NAME <- toupper(gsub('"', '', schema_info$COLUMN_NAME))
  
  # Step 3: Generate CREATE TABLE SQL
  create_table_sql <- paste0(glue(
    "CREATE OR REPLACE TABLE {schema}.{table_name} (",
    paste(paste(schema_info$COLUMN_NAME, schema_info$TYPE), collapse = ", "),
    ");"
  ))
  
  
  
  # Execute the CREATE TABLE statement
  dbExecute(con, create_table_sql)
  
  
  # Copy into the Snowflake table
  dbExecute(db_connection, glue("
    COPY INTO {schema}.{table_name}
    FROM @{stage_name}/{basename(filepath)}
    FILE_FORMAT = '{schema}.r_file_format'
    MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;;
  "))
  
  # Clean up
  dbExecute(con, glue("REMOVE @{stage_name};"))
  
  message("Data uploaded successfully!")
}


filepath = "<file_path>"


# Usage
bulk_upload_to_snowflake(con = db_connection, 
                         filepath = normalizePath(filepath), 
                         schema = "<db_name>.<schema_name>", 
                         table_name = '<table_name>')



