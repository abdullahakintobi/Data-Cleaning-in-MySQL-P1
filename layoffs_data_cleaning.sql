-- Project Title: Layoffs Data Cleaning in MySQL
-- By: Abdullah Akintobi
-- Published On: November 12, 2024

-- -------------------------------------------------------
-- Data Modeling
-- -------------------------------------------------------

-- Create Database
CREATE DATABASE world_layoffs;

-- Data Archiving
-- Create a duplicate of the dataset as a backup
CREATE TABLE layoffs_copy LIKE layoffs;

-- Populate the backup table 'layoffs_copy' with data from 'layoffs'
INSERT INTO layoffs_copy
SELECT *
FROM layoffs;

-- Preview the newly populated table
SELECT *
FROM layoffs_copy;

-- -------------------------------------------------------
-- Data Exploration
-- -------------------------------------------------------

-- Preview 10 random samples from 'layoffs_copy'
SELECT *
FROM layoffs_copy
ORDER BY RAND()
LIMIT 10;

-- Count the number of rows in the table
SELECT COUNT(*) AS row_num
FROM layoffs_copy;

-- Check for Duplicates using ROW_NUMBER() window function
WITH duplicate AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY `company`, `location`, `industry`, `total_laid_off`,
            `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`
        ) AS dub_row_num
    FROM layoffs_copy
)
SELECT *
FROM duplicate
WHERE dub_row_num > 1;

-- -------------------------------------------------------
-- Data Cleaning
-- -------------------------------------------------------

-- Create a new table to remove duplicates
CREATE TABLE layoffs_clean (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` FLOAT DEFAULT NULL,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `dub_row_num` INT
) ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE=UTF8MB4_0900_AI_CI;

-- Populate 'layoffs_clean' with data and add row number to identify duplicates
INSERT INTO layoffs_clean
SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY `company`, `location`, `industry`, `total_laid_off`,
        `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`
    ) AS dub_row_num
FROM layoffs_copy;

-- Preview duplicates
SELECT *
FROM layoffs_clean
WHERE dub_row_num > 1;

-- Delete duplicates and re-run the insert statement to confirm changes
DELETE FROM layoffs_clean
WHERE dub_row_num > 1;

-- Remove the 'dub_row_num' column as it's no longer needed
ALTER TABLE layoffs_clean
DROP COLUMN dub_row_num;

-- -------------------------------------------------------
-- Data Standardization
-- -------------------------------------------------------

-- Preview data
SELECT *
FROM layoffs_clean;

-- Check distinct companies
SELECT DISTINCT company
FROM layoffs_clean
ORDER BY 1;

-- Trim whitespace from company names
UPDATE layoffs_clean
SET company = TRIM(company);

-- Check distinct industries
SELECT DISTINCT industry
FROM layoffs_clean
ORDER BY 1;

-- Filter industries containing 'Crypto'
SELECT DISTINCT industry
FROM layoffs_clean
WHERE industry LIKE 'Crypto%';

-- Standardize 'Crypto' industries
UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Check distinct countries
SELECT DISTINCT country
FROM layoffs_clean
ORDER BY 1;

-- Correct country name errors
UPDATE layoffs_clean
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Check distinct date values
SELECT DISTINCT `date`
FROM layoffs_clean;

-- Convert the date column to a standardized date format
UPDATE layoffs_clean
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter the date column to DATE datatype
ALTER TABLE layoffs_clean
MODIFY COLUMN `date` DATE;

-- Check rows with empty or NULL industry values
SELECT *
FROM layoffs_clean
WHERE industry IS NULL OR industry = '';

-- Set empty rows in the industry column to NULL
UPDATE layoffs_clean
SET industry = NULL
WHERE industry = '';

-- Fill NULL industry values by matching on company and location
UPDATE layoffs_clean AS t1
INNER JOIN layoffs_clean AS t2 
  ON t1.company = t2.company
  AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Check remaining NULL values in the industry column. 
-- Note: "Bally's Interactive" company still have NULL values due to a lack of matching records in the dataset to determine its industry.
SELECT *
FROM layoffs_clean
WHERE industry IS NULL;

-- Identify rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
SELECT *
FROM layoffs_clean
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Delete rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
DELETE FROM layoffs_clean
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- END OF PROJECT