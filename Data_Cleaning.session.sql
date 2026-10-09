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
FROM layoffs_staging2;


--EXPLORATORY DATA ANALYSIS
--@block
SELECT *
FROM layoffs_staging2;

--@block
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

--@block
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

--@block
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

--@block
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

--@block
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

--@block
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

--@block
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

--@block
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

--extracting a part of a date and summing a metric per group.
--@block
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- --@block
-- SELECT
--   YEAR(`date`)  AS `YEAR`,
--   MONTH(`date`) AS `MONTH`,
--   SUM(total_laid_off) AS total_laid
-- FROM layoffs_staging2
-- GROUP BY `YEAR`, `MONTH`
-- ORDER BY `YEAR`, `MONTH`;

-- --@block
-- SELECT
--   SUBSTRING(`date`, 1, 4) AS `YEAR`,
--   SUBSTRING(`date`, 6, 2) AS `MONTH`,
--   SUM(total_laid_off) AS total_laid
-- FROM layoffs_staging2
-- GROUP BY `YEAR`, `MONTH`
-- ORDER BY `YEAR`, `MONTH`;

--@block
WITH Rolling_Total AS(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

--TOTAL_LAID_OFF PER YEAR FOR EACH COMPANY
--@block
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Step 1: Total layoffs per company per year
--@block
WITH Company_year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
-- Step 2: Rank companies within each year by layoffs
Company_Year_Rank AS
(
SELECT * , DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;


























