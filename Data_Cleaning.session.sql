--@block
USE world_layoffs;
--@block
CREATE TABLE layoffs (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT
);
--@block
LOAD DATA LOCAL INFILE '/home/triza-museve/DATA CLEANING WITH SQL/layoffs.csv' INTO TABLE layoffs FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
--@block;
SELECT *
FROM layoffs --@block
    CREATE TABLE layoffs_staging LIKE layoffs;
--@block
SELECT *
FROM layoffs_staging --@block
INSERT layoffs_staging --STEP 1
    --REMOVING DUPLICATES
    --@block
    WITH duplicate_cte AS(
        SELECT *,
            ROW_NUMBER() OVER(
                PARTITION BY company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                country,
                stage,
                funds_raised_millions
            ) AS row_num
        FROM layoffs_staging
    )
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
--@block
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';
--@block
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);
--@block
SELECT *
FROM layoffs_staging2;
--@block
INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        country,
        stage,
        funds_raised_millions
    ) AS row_num
FROM layoffs_staging;
--@block
DELETE FROM layoffs_staging2
WHERE row_num > 1;
--STEP 2
--STANDARDIZING DATA  
--@block
SELECT company,
    TRIM(company)
FROM layoffs_staging2;
--@block
UPDATE layoffs_staging2
SET company = TRIM(company);
--@block
SELECT DISTINCT industry
FROM layoffs_staging2;
--@block
SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';
--@block
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' --@block
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;
--@block
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
--@block
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%' --@block
SELECT @@autocommit;
--@block
SHOW VARIABLES LIKE 'log_bin';
--@block
SHOW BINARY LOGS;
--@block
SHOW BINLOG EVENTS IN 'binlog.000174'
LIMIT 50;
--@block
SHOW VARIABLES LIKE 'datadir';
--@block
DESC layoffs_staging2;
--@block
SELECT `date`,
    STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
--@block
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
--@block
SELECT *
FROM layoffs_staging2;
--@block
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
--STEP 3
--DEALING WITH NULL/BLANK VALUES
--@block
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
    AND percentage_laid_off IS NULL;
--@block
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
    OR industry = '';
--@block
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
--@block
SELECT t1.industry,
    t2.industry
FROM layoffs_staging2 t1
    JOIN layoffs_staging2 t2 ON t1.company = t2.company
WHERE (
        t1.industry IS NULL
        OR t1.industry = ''
    )
    AND t2.industry IS NOT NULL;
--@block
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
--@block
UPDATE layoffs_staging2 t1
    JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (
        t1.industry IS NULL
        OR t1.industry = ''
    )
    AND t2.industry IS NOT NULL;
--REMOVING IRRELEVANT COLUMNS/ROWS
--@block
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
    AND percentage_laid_off IS NULL;
--@block
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
--@block
SELECT *
FROM layoffs_staging2