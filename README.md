# r-snowflake-uploader

An R script that automates the end-to-end process of uploading local data files to Snowflake. It handles staging, schema inference, table creation, and data loading — then cleans up the stage when done.

---

## Features

- 📤 **Upload to Snowflake internal stage** — Transfers local data files directly to a Snowflake internal stage
- 🔍 **Automatic schema inference** — Detects column names and data types from the file without manual configuration
- 🏗️ **Table creation** — Automatically creates a destination table based on the inferred schema
- 📥 **Data loading** — Loads the staged file into the newly created table using Snowflake's `COPY INTO` command
- 🧹 **Stage cleanup** — Removes the uploaded file from the internal stage after loading is complete

---

## Prerequisites

- R (version 4.0 or higher recommended)
- A Snowflake account with appropriate permissions (CREATE TABLE, PUT, COPY INTO, LIST/REMOVE stage)
- The following R packages:
  - [`DBI`](https://cran.r-project.org/package=DBI)
  - [`odbc`](https://cran.r-project.org/package=odbc) or [`RJDBC`](https://cran.r-project.org/package=RJDBC) (depending on your Snowflake driver setup)
  - [`dplyr`](https://cran.r-project.org/package=dplyr) *(if used for schema inference)*

Install packages with:
```r
install.packages(c("DBI", "odbc", "dplyr"))
```

---

## Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rahulmuralidharanGH/r-snowflake-uploader.git
   cd r-snowflake-uploader
   ```

2. **Configure your Snowflake connection** in the script by setting the following variables:
   ```r
   account   <- "your_account_identifier"
   user      <- "your_username"
   password  <- "your_password"
   warehouse <- "your_warehouse"
   database  <- "your_database"
   schema    <- "your_schema"
   ```
   > ⚠️ **Security tip:** Avoid hardcoding credentials. Consider using environment variables or a `.Renviron` file instead.

3. **Specify your data file path** and target table name in the script.

---

## Usage

Open and run `Data upload from R.R` in RStudio or from the command line:

```bash
Rscript "Data upload from R.R"
```

The script will:
1. Connect to your Snowflake instance
2. Upload the specified file to the internal stage
3. Infer the schema from the file
4. Create the target table in Snowflake
5. Load the data from the stage into the table
6. Remove the file from the stage

---

## Notes

- Supported file formats depend on Snowflake's `COPY INTO` capabilities (CSV, JSON, Parquet, etc.)
- If the target table already exists, the script may need modification to handle `CREATE OR REPLACE` vs. `INSERT` behavior
- Ensure your Snowflake role has sufficient privileges for all operations

---

## License

This project is open source. See [LICENSE](LICENSE) for details.

---

## Contributing

Contributions and improvements are welcome! Feel free to open an issue or submit a pull request.
