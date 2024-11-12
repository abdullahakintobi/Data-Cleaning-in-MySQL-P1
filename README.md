# Layoffs Data Cleaning in MySQL

**Author**: Abdullah Akintobi  
**DBMS**: MySQL  
**Date Published**: November 12, 2024


## Project Overview

This project uses MySQL to clean and standardize data in a `layoffs` dataset. Key processes include Data Modeling, Exploration, Data Cleaning, and Data Standardization. The goal is to create a clean, standardized dataset that is free of duplicates, inconsistencies, and null values to enable accurate analysis of `layoffs` data

---

## 1. Data Modeling

### Database and Table Creation

1. **Database**: Created a dedicated database called `world_layoffs`.
   ```sql
   CREATE DATABASE world_layoffs;
   ```
- **Column Descriptions**: Details of each column in the `layoffs` dataset
  - `company`: Company name
  - `location`: Location of the company
  - `industry`: Industry sector
  - `total_laid_off`: Number of employees laid off
  - `percentage_laid_off`: Percentage of workforce laid off
  - `date`: Date of layoff
  - `stage`: Company stage
  - `country`: Country of operation
  - `funds_raised_millions`: Funds raised in millions
- **Column Data Types**: Data types of each column upon import
   ```sql
   CREATE TABLE layoffs (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` FLOAT DEFAULT NULL,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL
   );
   ```
2. **Data Archiving**: Backed up the original dataset to ensure data preservation before any transformations.
   ```sql
   CREATE TABLE layoffs_copy LIKE layoffs;

   INSERT INTO layoffs_copy
   SELECT *
   FROM layoffs;
   ```


## 2. Data Exploration

### Basic Data Insights

1. **Preview Random Samples**: Selected 10 random rows to understand the data layout.
    ```sql
    SELECT *
    FROM layoffs_copy
    ORDER BY RAND()
    LIMIT 10;
    ```
2. **Row Count**: Verified the total number of rows.
    ```sql
    SELECT COUNT(*) AS row_num
    FROM layoffs_copy;
    ```
3. **Duplicate Check**: Used a window function to identify duplicate rows based on key fields.
    ```sql
    WITH duplicate AS (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY `company`, `location`, `industry`, `total_laid_off`,
                   `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`
               ) AS dub_row_num
        FROM layoffs_copy
    )
    SELECT *
    FROM duplicate
    WHERE dub_row_num > 1;
    ```


## 3. Data Cleaning

### Duplicate Removal and Column Adjustments

1. **Clean Table Creation**: Created new table `layoffs_clean` with row numbers for duplicate identification
    ```sql
    CREATE TABLE layoffs_clean AS
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY `company`, `location`, `industry`, `total_laid_off`,
               `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`
           ) AS dub_row_num
    FROM layoffs_copy;
    ```
2. **Duplicate Removal**: Removed identified duplicate records
    ```sql
    DELETE FROM layoffs_clean
    WHERE dub_row_num > 1;
    ```
3. **Structure Cleanup**: Removed temporary duplicate identifier column
    ```sql
    ALTER TABLE layoffs_clean
    DROP COLUMN dub_row_num;
    ```


## 4. Data Standardization

### Data Consistency and Null Handling

1. **Company Names**: Trimmed whitespace from company names
    ```sql
    UPDATE layoffs_clean
    SET company = TRIM(company);
    ```

2. **Industry Names**: Standardized industry classifications
    ```sql
    UPDATE layoffs_clean
    SET industry = 'Crypto'
    WHERE industry IN ('Crypto Currency', 'CryptoCurrency');
    ```

3. **Country Names**: Corrected country name formats
    ```sql
    UPDATE layoffs_clean
    SET country = TRIM(TRAILING '.' FROM country)
    WHERE country LIKE 'United States%';
    ```

4. **Date Format**: Standardized date format and data type
    ```sql
    UPDATE layoffs_clean
    SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

    ALTER TABLE layoffs_clean
    MODIFY COLUMN `date` DATE;
    ```

### NULL Value Handling

1. **Industry NULL Values**: 
   - Standardized empty industry values by setting them to NULL for data consistency
   - Filled NULL industries using company and location matching
    ```sql
    UPDATE layoffs_clean
    SET industry = NULL
    WHERE industry = '';

    UPDATE layoffs_clean AS t1
    INNER JOIN layoffs_clean AS t2 
    ON t1.company = t2.company
    AND t1.location = t2.location
    SET t1.industry = t2.industry
    WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;
    ```

2. **Incomplete Records**: Removed records with insufficient layoff information
    ```sql
    DELETE FROM layoffs_clean
    WHERE total_laid_off IS NULL
    AND percentage_laid_off IS NULL;
    ```

---

## Summary Insights

The data cleaning process revealed and addressed several key issues:

- **Data Quality**: Identified and removed duplicate records to ensure data integrity
- **Standardization**: Implemented consistent formats for company names, industries, and countries
- **Missing Data**: Developed strategies for handling NULL values in critical fields
- **Date Formatting**: Converted string dates to proper DATE format for better analysis
- **Data Completeness**: Removed records lacking essential layoff information

## Conclusion

This project demonstrates a systematic approach to data cleaning in MySQL, implementing various techniques to ensure data quality and consistency. The cleaned dataset is now properly structured for further analysis, with standardized formats and reduced NULL values. The modular SQL queries provide a reusable framework for similar data cleaning tasks.

## About this project

This project is part of my portfolio, showcasing MySQL data cleaning and standardization skills essential for data analysis roles. The techniques demonstrated here are fundamental to ensuring data quality in analytical processes.

### Contact
- **LinkedIn**: [Abdullah Akintobi](https://www.linkedin.com/in/abdullahakintobi/)
- **X**: [@AkintobiAI](https://x.com/AkintobiAI)

Thank you for your time, and I look forward to connecting with you!