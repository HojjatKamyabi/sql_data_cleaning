# Data Cleaning Using SQL

## Overview

This project demonstrates how to clean a dataset <a href="https://catalog.data.gov/dataset/motor-vehicle-repair-and-towing">(Motor Vehicle Repair and Towing)</a> using SQL queries. The dataset contains car repair business registrations, and the cleaning process involves removing duplicates, standardizing data, handling null values, and performing exploratory data analysis (EDA).

## Steps in Data Cleaning

### 1. Staging: Creating a Clone of the Main Table

  A staging table (car_repair_staging) is created as a copy of the original dataset (car_repair).

This ensures that the cleaning process does not affect the original data.

### 2. Handling Duplicates

* A row_number column is generated using a Common Table Expression (CTE) to identify duplicate records.

* A new staging table is created to store deduplicated data.

* Duplicate entries are deleted, retaining only the first occurrence.

### 3. Standardizing Data

* Trimming extra spaces from string columns.

* Standardizing state abbreviations (e.g., replacing variations of "Maryland" with "MD").

* Converting date columns from text format to proper DATE type using STR_TO_DATE.

### 4. Handling Blank/Null Values

* Replacing blank values with NULL.
 
* Filling missing values using related data from other rows.

* Dropping the extra row_num column used for duplicate handling.

### 5. Exploratory Data Analysis (EDA)

* Counting the number of car repair registrations per city.

* Counting the number of registrations per corporation.

* Analyzing the number of issued registrations by month and year.

* Calculating a rolling total of registrations per month.

* Ranking corporations based on the number of issued registrations per year.

## SQL Techniques Used

* Common Table Expressions (CTEs)

* Window Functions (ROW_NUMBER(), DENSE_RANK(), SUM() OVER())

* Aggregate Functions (COUNT(), GROUP BY, ORDER BY)

* String Functions (TRIM(), LIKE)

* Date Functions (STR_TO_DATE(), YEAR(), SUBSTRING())

* Joins (JOIN to fill missing values)

