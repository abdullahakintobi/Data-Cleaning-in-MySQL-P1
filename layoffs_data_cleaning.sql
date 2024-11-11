-- Project Title: Layoffs Data Cleaning in MySQL
-- By: Abdullah Akintobi
-- Published On: November 11, 2024
--
--
-- -- Data Modelling --
-- Create Database
CREATE DATABASE world_layoffs;
-- Data Archiving
-- Create a dublicate of the dataset as a backup dataset
CREATE TABLE layoffs_copy LIKE layoffs;
-- Populate the new backup table 'layoffs_raw' with data from 'layoffs' table
INSERT
    layoffs_copy
SELECT
    *
FROM
    layoffs;
-- Preview the newly populated table
SELECT 
    *
FROM
    layoffs_copy;
--
--
-- Data Exploration
-- Preview 10 samples from 'layoffs' table
SELECT 
    *
FROM
    layoffs_copy
ORDER BY RAND()
LIMIT 10;
--
-- Count the number of rows in the table
SELECT 
    COUNT(*) AS row_num
FROM
    layoffs_copy;
-- Check for Duplicates using 'ROW_NUMBER()' window function
WITH dublicate AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY `company`,
            `location`,
            `industry`,
            `total_laid_off`,
            `percentage_laid_off`,
            `date`,
            `stage`,
            `country`,
            `funds_raised_millions`
        ) AS dub_row_num
    FROM
        layoffs_copy
)
SELECT
    *
FROM
    dublicate
WHERE
	dub_row_num > 1;
--
--
-- -- Data Cleaning --
-- Create new table to remove duplicates
CREATE TABLE `layoffs_clean` (
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
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;
-- Populate the new table with data from 'layoffs_copy' and row number to identify duplicates
INSERT INTO
    layoffs_clean
SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY `company`,
        `location`,
        `industry`,
        `total_laid_off`,
        `percentage_laid_off`,
        `date`,
        `stage`,
        `country`,
        `funds_raised_millions`
    ) AS dub_row_num
FROM
    layoffs_copy;
-- Preview duplicates
SELECT 
    *
FROM
    layoffs_clean
WHERE
    dub_row_num > 1;
-- Delete duplicates and re-run code-line 99-104 above to confirm changes
DELETE FROM layoffs_clean 
WHERE
    dub_row_num > 1;
-- Delete 'dub_row_num' column as it's not useful anymore
ALTER TABLE layoffs_clean
DROP COLUMN dub_row_num;
--
--
-- Data Standardisation
-- Preview Data
SELECT
	*
FROM
	layoffs_clean;
--
-- Check different companies
SELECT
	DISTINCT company
FROM
	layoffs_clean
ORDER BY 1;
-- Trim companies with white spaces. Re-run last query to confirm changes
UPDATE layoffs_clean
SET company = TRIM(company);
--
-- Check different industries
SELECT
	DISTINCT industry
FROM
	layoffs_clean
ORDER BY 1;
-- Check industies like Crypto
SELECT
    *
FROM
    layoffs_clean
WHERE
    industry LIKE 'Crypto%';
-- Update Crypto industries
UPDATE
    layoffs_clean
SET
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';
--
-- Check different countries
SELECT
	DISTINCT country
FROM
	layoffs_clean
ORDER BY 1;
-- Correct the error in the country column
UPDATE layoffs_clean
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
--
-- Check the date column
SELECT
	DISTINCT(`date`)
FROM
	layoffs_clean;
-- Convert the date column to a date format
UPDATE layoffs_clean
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- Convert the date column to a DATE datatype
ALTER TABLE layoffs_clean
MODIFY COLUMN `date` DATE;








--
SELECT
	*
FROM
	layoffs_clean
LIMIT 10;
	
	