# Analyzing US Consumer Spending Trends Using Monthly Retail Sales Data (1992–2024)

Collected and transformed 30+ years of monthly retail sales data from the US Census Bureau. Cleaned and transformed data using Excel Macros and merged seperated year-wise data into unified format, then imported to BigQuery. Performed SQL-based exploratory and time-series analysis to uncover trends, seasonality, and subcategory growth patterns. Visualized results using Matplotlib integrating Python with bigquery.

## Project Overview

- **Data Source**: U.S. Census Bureau : [Retail and Food Services Sales Excel Dataset](https://www.census.gov/retail/index.html)
- **Time Period**: 1992–2025
- **Granularity**: Monthly sales (in millions USD), both total and subcategory-wise
- **Tools Used**: Excel (Macros, Power Query), Google BigQuery (SQL), Python (matplotlib, pandas)

## Workflow Summary

1. **Data Cleaning & Prep**
   - Cleaned raw Excel files using VBA Macros to remove footnotes, standardize formats, and automate repetitive cleanup tasks.
   - Used Power Query to transform and reshape the data and merged year-wise sheets (1992–2024) into a single consolidated table
   - Exported the cleaned dataset to CSV and imported it into Google BigQuery for scalable analysis

3. **SQL Analysis (BigQuery)**
   - Time-series trends (monthly, yearly)
   - Subcategory comparison (Books, Hobby, Sporting Goods)
   - Gendered sales comparison (Men’s vs. Women’s clothing)
   - Seasonality & rolling averages
   - YOY growth, percent change, cumulative sales, percent-of-total breakdowns
   - Indexing and benchmarking strategies
     
4. **Visualizations**
   - Created time-series and comparative line charts to uncover trends
   - Indexed and normalized series to analyze relative growth

## SQL Techniques Used in **Google BigQuery**:
### Time Series & Aggregations
   - `EXTRACT(YEAR FROM date)`, `SUM()`, `ROUND()`
   - Grouping by `year`, `sales_month`, and `kind_of_business` to uncover long-term trends

### Window Functions
   - `LAG()` – Compare values from the previous month/year
   - `FIRST_VALUE()` – Calculate index-based growth from the baseline year (1992)
   - `SUM(...) OVER (...)` – Compute cumulative totals (e.g., year-to-date)
   - `AVG(...) OVER (...)`, `COUNT(...) OVER (...)` – Create moving averages and rolling metrics

### Conditional Aggregation
   - `CASE WHEN` – Used to compute gaps and ratios between categories (e.g., women’s vs. men’s clothing sales)

### Percent Calculations
   - Calculate monthly share of yearly or total sales
   - Determine year-over-year (YoY) growth and percent change
   - Analyze percent difference and sales ratios between subcategories

### Rolling Time Windows
   - Used **self-joins** and date math (`DATE_SUB()`) to implement 12-month rolling analysis windows

These techniques helped uncover **seasonality trends**, **COVID-19 impacts**, and **category-specific consumer behavior shifts** over time.



## Key Insights Highlight

**Overall Retail Sales Trend**
   - Clear long-term growth trend in U.S. retail and food services sales. The only major declines occurred in 2009 (global financial crisis) and 2020 (COVID-19 pandemic). Sales rebounded strongly post-2020 and reached their highest point in 2025, crossing $9 million USD, continuing the upward trajectory.
     ![image](https://github.com/user-attachments/assets/a7050496-2a1d-4858-a32c-f19e47d6fb9a)


**Leisure Categories: Book, Hobby, and Sporting Goods Stores**
   - Sporting goods stores led all three categories in growth and peaked around 2021, likely driven by pandemic-fueled outdoor activity interest. Though slightly declining after 2022, they still remain far above the other categories.
   - Book stores saw a steady decline from the mid-2000s, likely due to digital transformation and the rise of e-commerce platforms.
     ![image](https://github.com/user-attachments/assets/640568e7-cea5-4618-9cfb-ae08998c3598)


**Women’s vs. Men’s Clothing Sales**
   - Women's clothing consistently outperformed men's, with the gap widening during the early 2000s and reaching a significant peak in the 2010s.
   - Both categories declined sharply in 2020, but women's sales recovered quickly, while men's clothing sales have continued to decline post-2020, contributing to a growing disparity.
   - Ratio and percent-difference analysis confirmed that women's clothing sales have been 2.5x to 4x higher than men’s in recent years.
     ![image](https://github.com/user-attachments/assets/acdddbf6-66f9-4362-a227-0531f839d756)


**Seasonality & Monthly Changes**
  - Strong seasonality patterns were visible in categories like book stores, with recurring spikes (likely around holidays or back-to-school seasons).
    ![image](https://github.com/user-attachments/assets/e2dd83b2-f1b5-4eaa-bf4a-ab2880ba43bf)

  - Month-over-month percent change and year-over-year (YoY) comparisons revealed that: The biggest disruption came in 2020, with negative YoY growth for several categories. 2021 showed massive recovery, especially in women’s clothing and sporting goods.


## References

- **Data Source**:  
  U.S. Census Bureau. *Monthly Retail Trade Report: Retail and Food Services Sales (1992–present)*  
  [https://www.census.gov/retail/index.html](https://www.census.gov/retail/index.html)

- **Why Retail Sales Matter**:  
  Retail sales data is used as a **leading economic indicator** to understand consumer behavior in the U.S. It is published **monthly**, ahead of quarterly GDP figures, and is often covered in financial media to forecast economic momentum.

- **Economic Context Referenced**:
  - 2008–2009: Global Financial Crisis
  - 2020: COVID-19 Pandemic and its economic impact
  - Post-2020: Recovery patterns and consumer rebound visible in retail categories such as sporting goods and apparel

- **BigQuery SQL Documentation**: [https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)

- **Book Reference**:  
  Molinaro, Cathy T. *SQL for Data Analysis: Advanced Techniques for Transforming Data into Insights*. O’Reilly Media, 2020.  
  [(https://www.oreilly.com/library/view/sql-for-data/9781492088776/)](https://www.oreilly.com/library/view/sql-for-data/9781492088776/)
