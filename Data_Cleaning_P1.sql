SELECT *
FROM layoffs;

CREATE TABLE layoffs_raw
LIKE layoffs;

SELECT *
FROM layoffs_raw;

INSERT layoffs_raw
SELECT *
FROM layoffs;

SELECT
    *,
    COUNT(*) as duplicate_count
FROM
    layoffs
GROUP BY
    company
HAVING
    COUNT(*) > 1;

WITH dublicate_count AS (
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
        ) AS NUM_DUBLICATE
    FROM
        layoffs
)
SELECT
    COUNT(*)
FROM
    dublicate_count;
WITH COUNT_ROW AS (
    SELECT
        *,
        COUNT(*) NUM_DUBLICATE
    FROM
        layoffs
    GROUP BY
        `company`,
        `location`,
        `industry`,
        `total_laid_off`,
        `percentage_laid_off`,
        `date`,
        `stage`,
        `country`,
        `funds_raised_millions`
)
SELECT
    COUNT(*)
FROM
    COUNT_ROW;

SELECT COUNT(*)
FROM layoffs;

CREATE TABLE `layoffs_clean` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` int DEFAULT NULL,
    `percentage_laid_off` float DEFAULT NULL,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int DEFAULT NULL,
    `row_num` int
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_clean;
--
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
    ) AS row_num
FROM
    layoffs;
DROP TABLE layoffs_clean;