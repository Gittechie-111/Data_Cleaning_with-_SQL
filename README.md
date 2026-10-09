# Global Layoffs Analysis (MySQL)

A SQL project that cleans and analyzes a raw dataset of global tech layoffs
spanning 2020–2023, using MySQL for transformation and exploratory analysis.

## Dataset

The raw data (`layoffs.csv`) contains records of company layoffs, with the
following fields:

- `company` — name of the company
- `location` — city / region
- `industry` — sector (e.g. Consumer, Retail, Crypto)
- `total_laid_off` — number of employees laid off
- `percentage_laid_off` — fraction of workforce laid off (0–1)
- `date` — date of the layoff event
- `stage` — funding stage (e.g. Post-IPO, Series B)
- `country` — country of the company
- `funds_raised_millions` — total funds raised, in millions

## Tools Used

- **MySQL 8** — data cleaning and analysis
- **VS Code** with the SQLTools extension
- **Git / GitHub** — version control

## Project Structure

| File | Description |
|---|---|
| `layoffs.csv` | Raw, uncleaned dataset |
| `data_cleaning.sql` | Cleaning pipeline: dedup, standardize, handle nulls |
| `exploratory_data_analysis.sql` | EDA queries: totals, trends, rankings |
| `README.md` | This document |

## Data Cleaning Steps

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

## Exploratory Analysis

The `exploratory_data_analysis.sql` file answers questions such as:

- **Overall magnitude** — maximum single layoff event and maximum percentage laid off
- **By company** — total layoffs per company, ranked
- **By industry** — which sectors were hit hardest
- **By country** — geographic distribution of layoffs
- **By funding stage** — where in the lifecycle layoffs concentrated
- **Time series** — layoffs aggregated by month and year
- **Rolling total** — cumulative layoffs over time using a window function
- **Top 5 companies per year** — using `DENSE_RANK()` partitioned by year

## Key SQL Concepts Used

- **CTEs (`WITH`)** for readable, layered queries
- **Window functions**: `DENSE_RANK() OVER (PARTITION BY ...)`, `SUM(...) OVER (ORDER BY ...)` for rolling totals
- **Aggregation**: `SUM`, `GROUP BY`, `ORDER BY` on aliased columns
- **Date handling**: `YEAR()`, `MONTH()`, `SUBSTRING()` on text-stored dates
- **Self-joins** for backfilling missing values
- **`ROW_NUMBER()`** for duplicate detection

## How to Reproduce

1. Clone this repository.
2. Open MySQL and create a database:

   ```sql
   CREATE DATABASE world_layoffs;
   USE world_layoffs;

3. Run data_cleaning.sql from top to bottom.

4. Then run exploratory_data_analysis.sql to explore the cleaned data.

Triza Museve — aspiring data analyst
https://github.com/Gittechie-111
