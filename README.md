# Layoffs Data Cleaning in MySQL

**Author**: Abdullah Akintobi  
**DBMS**: MySQL  
**Date Published**: November 11, 2024

---

## Project Overview

This project involves using MySQL to clean and standardize data in a layoffs dataset. Key processes include **Data Modeling**, **Data Exploration**, **Data Cleaning**, and **Data Standardization**. The goal is to create a clean, standardized dataset that is free of duplicates, inconsistencies, and null values to enable accurate analysis of layoffs data.

---

## 1. Data Modeling

### Database and Table Creation

- **Database**: Created a dedicated database called `world_layoffs`.
- **Data Archiving**: Backed up the original dataset to ensure data preservation before any transformations.
  ```sql
  CREATE DATABASE world_layoffs;

  CREATE TABLE layoffs_copy LIKE layoffs;

  INSERT INTO layoffs_copy
  SELECT *
  FROM layoffs;
  ```

---

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

---

## 3. Data Cleaning

### Duplicate Removal and Column Adjustments

1. **Duplicate Removal**: Created a clean table without duplicates.
    ```sql
    CREATE TABLE layoffs_clean AS
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY `company`, `location`, `industry`, `total_laid_off`,
               `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`
           ) AS dub_row_num
    FROM layoffs_copy;
    ```
2. **Duplicate Deletion**: Deleted rows with duplicate identifiers.
    ```sql
    DELETE FROM layoffs_clean
    WHERE dub_row_num > 1;
    ```
3. **Column Adjustment**: Removed the helper column `dub_row_num` after duplicate handling.
    ```sql
    ALTER TABLE layoffs_clean
    DROP COLUMN dub_row_num;
    ```

---

## 4. Data Standardization

### Data Consistency and Null Handling

1. **Whitespace and Naming Consistency**: Trimmed spaces from company names and standardized `Crypto` industry values.
    ```sql
    UPDATE layoffs_clean
    SET company = TRIM(company);

    UPDATE layoffs_clean
    SET industry = 'Crypto'
    WHERE industry IN ('Crypto Currency', 'CryptoCurrency');
    ```
2. **Country Name Correction**: Standardized country names for consistency.
    ```sql
    UPDATE layoffs_clean
    SET country = TRIM(TRAILING '.' FROM country)
    WHERE country LIKE 'United States%';
    ```
3. **Date Format Conversion**: Converted date values to a consistent format.
    ```sql
    UPDATE layoffs_clean
    SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
    ALTER TABLE layoffs_clean
    MODIFY COLUMN `date` DATE;
    ```
4. **Null Handling**: Addressed null values in `industry`, `total_laid_off`, and `percentage_laid_off`.
    ```sql
    UPDATE layoffs_clean
    SET industry = NULL
    WHERE industry = '';

    DELETE FROM layoffs_clean
    WHERE total_laid_off IS NULL
      AND percentage_laid_off IS NULL;
    ```

---

## Summary Insights

This project effectively demonstrates MySQL’s utility in data cleaning and preparation for analysis. The final dataset is devoid of duplicates, standardized, and ready for further exploration or analysis.

---

## Conclusion

This project showcases essential MySQL data manipulation skills for ensuring data quality. The structured approach makes it adaptable for similar data cleaning projects, especially those requiring data integrity and consistency.

---

## About this project

This project is a part of my portfolio, highlighting SQL skills in data cleaning and standardization. Feel free to reach out for questions or collaboration!

### Contact
- **LinkedIn**: [Abdullah Akintobi](https://www.linkedin.com/in/abdullahakintobi/)
- **X**: [@AkintobiAI](https://x.com/AkintobiAI)

Thank you for reviewing this project!