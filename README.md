# Global Layoffs Data Cleaning (MySQL)

A SQL data cleaning project that takes a raw dataset of global tech layoffs
and transforms it into a clean, analysis-ready table using MySQL.

## Dataset

The raw data (`layoffs.csv`) contains records of company layoffs including:
- Company name and location
- Industry
- Total employees laid off
- Percentage laid off
- Date, funding stage, and country
- Funds raised (in millions)

## Tools Used

- **MySQL** — data cleaning and transformation
- **VS Code** — with the SQLTools extension
- **Git / GitHub** — version control

## Cleaning Steps

The `data_cleaning.sql` script performs the following:

1. **Created a staging table** (`layoffs_staging`) as a copy of the raw data
   so the original is never modified.
2. **Removed duplicates** using `ROW_NUMBER()` over all columns and deleted
   rows where `row_num > 1`.
3. **Standardized text values:**
   - Trimmed whitespace from `company` names.
   - Unified variations of "Crypto" (e.g. `Crypto.com`, `Crypto Currency`)
     into a single value.
   - Removed trailing periods from `country` values
     (e.g. `United States.` → `United States`).
4. **Handled NULL / blank values** by joining the staging table back to
   itself on matching company + location + date to fill missing industries.
5. **Converted data types** for `date` and `total_laid_off` where needed.
6. **Removed rows with no usable layoff data** (both `total_laid_off`
   and `percentage_laid_off` were NULL).

## Files

| File | Description |
|---|---|
| `layoffs.csv` | Raw, uncleaned dataset |
| `data_cleaning.sql` | All SQL cleaning queries |
| `README.md` | Project documentation |

## Key SQL Concepts Used

- `ROW_NUMBER()` with `PARTITION BY` for duplicate detection
- `CREATE TABLE ... LIKE` and `INSERT INTO ... SELECT`
- Self-joins to populate missing values
- `UPDATE` with `LIKE` pattern matching for text standardization
- `DELETE` with CTEs (`WITH` clauses)

## How to Reproduce

1. Clone this repository.
2. Open MySQL and create a database:
   ```sql
   CREATE DATABASE world_layoffs;
   USE world_layoffs;

3. Run data_cleaning.sql in order, top to bottom.

4. Query the final table:
   ```sql
   SELECT * FROM layoffs_staging2;

Author
Triza Museve — aspiring data analyst
https://github.com/Gittechie-111



   

   
