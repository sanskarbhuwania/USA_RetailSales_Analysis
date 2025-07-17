-- View the full dataset (after importing cleaned data to BigQuery)
SELECT * FROM `bold-catfish-457021-f1.US_RETAIL_SALES.retail_sales`;

-- Explore raw monthly trend of total retail and food services sales
SELECT sales_month, sales
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
ORDER BY sales_month ASC;

-- Aggregate sales at yearly level to smooth out monthly noise and reveal overall trend
SELECT EXTRACT(YEAR FROM sales_month) AS year, 
       SUM(sales) AS sales
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
GROUP BY year
ORDER BY year;

-- Compare yearly sales for leisure categories: Book, Hobby/Toy/Game, and Sporting Goods
SELECT EXTRACT(YEAR FROM sales_month) AS year, 
       SUM(sales) AS sales,
       kind_of_business
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business IN ('Book stores','Sporting goods stores','Hobby, toy, and game stores')
GROUP BY year, kind_of_business
ORDER BY kind_of_business, year;

-- Get monthly and yearly sales trends for Men’s vs Women’s clothing
SELECT sales_month, SUM(sales) AS sales, kind_of_business
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business IN ('Women\'s clothing stores','Men\'s clothing stores')
GROUP BY sales_month, kind_of_business
ORDER BY kind_of_business;

SELECT EXTRACT(YEAR FROM sales_month) AS year, SUM(sales) AS sales, kind_of_business
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business IN ('Women\'s clothing stores','Men\'s clothing stores')
GROUP BY year, kind_of_business
ORDER BY kind_of_business, year;

-- Calculate the annual absolute sales gap between Women’s and Men’s clothing stores
SELECT EXTRACT(YEAR FROM sales_month) AS year, 
       SUM(CASE WHEN kind_of_business = 'Women\'s clothing stores' THEN sales END) -
       SUM(CASE WHEN kind_of_business = 'Men\'s clothing stores' THEN sales END) AS women_minus_men
FROM US_RETAIL_SALES.retail_sales
GROUP BY year
ORDER BY year;

-- Filter out years with incomplete (NULL) men’s clothing data
SELECT EXTRACT(YEAR FROM sales_month) AS year,
       SUM(CASE WHEN kind_of_business = 'Women\'s clothing stores' THEN sales END) - 
       SUM(CASE WHEN kind_of_business = 'Men\'s clothing stores' THEN sales END) AS women_minus_men
FROM US_RETAIL_SALES.retail_sales
WHERE EXTRACT(YEAR FROM sales_month) < 2022
GROUP BY year
ORDER BY year;

-- Calculate yearly ratio of Women’s to Men’s clothing store sales
SELECT year,
       ROUND(womens_sales / mens_sales, 4) AS womens_times_of_mens
FROM (
  SELECT EXTRACT(YEAR FROM sales_month) AS year,
         SUM(CASE WHEN kind_of_business = 'Women\'s clothing stores' THEN sales END) AS womens_sales,
         SUM(CASE WHEN kind_of_business = 'Men\'s clothing stores' THEN sales END) AS mens_sales
  FROM US_RETAIL_SALES.retail_sales
  WHERE kind_of_business IN ('Men\'s clothing stores','Women\'s clothing stores')
    AND EXTRACT(YEAR FROM sales_month) < 2022
  GROUP BY year
);

-- Compute percent difference of women’s clothing sales over men’s
SELECT year,
       ROUND((womens_sales / mens_sales - 1) * 100, 2) AS women_percent_of_men
FROM (
  SELECT EXTRACT(YEAR FROM sales_month) AS year,
         SUM(CASE WHEN kind_of_business = 'Women\'s clothing stores' THEN sales END) AS womens_sales,
         SUM(CASE WHEN kind_of_business = 'Men\'s clothing stores' THEN sales END) AS mens_sales
  FROM US_RETAIL_SALES.retail_sales
  WHERE kind_of_business IN ('Men\'s clothing stores','Women\'s clothing stores')
    AND EXTRACT(YEAR FROM sales_month) < 2022
  GROUP BY year
);

-- Calculate monthly share of total sales (for each sales_month)
SELECT sales_month, kind_of_business, sales,
       SUM(sales) OVER (PARTITION BY sales_month) AS total_sales,
       ROUND(sales * 100 / SUM(sales) OVER (PARTITION BY sales_month), 2) AS percent_total
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business IN ('Men\'s clothing stores','Women\'s clothing stores');

-- Find what percent of yearly total each monthly value represents
SELECT sales_month, sales,
       ROUND(100.0 * sales / SUM(sales) OVER (PARTITION BY EXTRACT(YEAR FROM sales_month)), 2) AS percent_of_yearly
FROM US_RETAIL_SALES.retail_sales;

-- Add percent contribution to yearly totals, split by kind_of_business
SELECT sales_month, kind_of_business, sales,
       SUM(sales) OVER (PARTITION BY EXTRACT(YEAR FROM sales_month), kind_of_business) AS yearly_sales,
       sales * 100 / SUM(sales) OVER (PARTITION BY EXTRACT(YEAR FROM sales_month), kind_of_business) AS percent_yearly
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business IN ('Men\'s clothing stores','Women\'s clothing stores');

-- Use 1992 sales as base year index for time series comparison
SELECT sales_year, sales,
       FIRST_VALUE(sales) OVER (ORDER BY sales_year) AS index
FROM (
  SELECT EXTRACT(YEAR FROM sales_month) AS sales_year, SUM(sales) AS sales
  FROM US_RETAIL_SALES.retail_sales
  WHERE kind_of_business = 'Women\'s clothing stores'
  GROUP BY sales_year
);

-- Calculate percent growth from index (1992) for women’s clothing
SELECT sales_year, sales,
       100 * (sales / FIRST_VALUE(sales) OVER (ORDER BY sales_year) - 1) AS percent_of_index
FROM (
  SELECT EXTRACT(YEAR FROM sales_month) AS sales_year, SUM(sales) AS sales
  FROM US_RETAIL_SALES.retail_sales
  WHERE kind_of_business = 'Women\'s clothing stores'
  GROUP BY sales_year
);

-- Index growth calculation for both genders
SELECT sales_year, kind_of_business, sales,
       100 * (sales / FIRST_VALUE(sales) OVER (PARTITION BY kind_of_business ORDER BY sales_year) - 1) AS percent_of_index
FROM (
  SELECT EXTRACT(YEAR FROM sales_month) AS sales_year, kind_of_business, SUM(sales) AS sales
  FROM US_RETAIL_SALES.retail_sales
  WHERE kind_of_business IN ('Women\'s clothing stores','Men\'s clothing stores')
  GROUP BY sales_year, kind_of_business
);

-- Get monthly sales (post 2024) for rolling window setup
SELECT sales_month, SUM(sales)
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Women\'s clothing stores'
  AND sales_month >= '2024-01-01'
GROUP BY kind_of_business, sales_month;

-- Rolling 12-month window using self join (to simulate rolling annual sales)
SELECT a.sales_month, a.sales,
       b.sales_month AS rolling_sales_month, b.sales AS rolling_sales
FROM US_RETAIL_SALES.retail_sales a
JOIN US_RETAIL_SALES.retail_sales b
  ON a.kind_of_business = b.kind_of_business
 AND b.sales_month BETWEEN DATE_SUB(a.sales_month, INTERVAL 11 MONTH) AND a.sales_month
 AND b.kind_of_business = 'Women\'s clothing stores'
WHERE a.kind_of_business = 'Women\'s clothing stores'
  AND a.sales_month = '2024-12-01';

-- Compute rolling 12-month average using join
SELECT a.sales_month, a.sales,
       ROUND(AVG(b.sales), 3) AS moving_avg,
       COUNT(b.sales) AS records_count
FROM US_RETAIL_SALES.retail_sales a
JOIN US_RETAIL_SALES.retail_sales b
  ON a.kind_of_business = b.kind_of_business
 AND b.sales_month BETWEEN DATE_SUB(a.sales_month, INTERVAL 11 MONTH) AND a.sales_month
WHERE a.kind_of_business = 'Women\'s clothing stores'
  AND a.sales_month >= '1993-01-01'
GROUP BY a.sales_month, a.sales
ORDER BY a.sales_month;

-- Use window function for rolling calculations
SELECT sales_month,
       AVG(sales) OVER (ORDER BY sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS moving_avg,
       COUNT(sales) OVER (ORDER BY sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS records_count
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Women\'s clothing stores'
ORDER BY sales_month;

-- Calculate year-to-date cumulative sales (resets each year)
SELECT sales_month, sales,
       SUM(sales) OVER (PARTITION BY EXTRACT(YEAR FROM sales_month) ORDER BY sales_month) AS sales_ytd
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Women\'s clothing stores'
ORDER BY sales_month;

-- Get previous month and previous month sales (for seasonality benchmarking)
SELECT kind_of_business, sales_month, sales,
       LAG(sales_month) OVER (PARTITION BY kind_of_business ORDER BY sales_month) AS prev_month,
       LAG(sales) OVER (PARTITION BY kind_of_business ORDER BY sales_month) AS pprev_month_sales
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Book stores';

-- Calculate percent change from previous month sales
SELECT kind_of_business, sales_month, sales,
       ROUND((sales / LAG(sales) OVER (PARTITION BY kind_of_business ORDER BY sales_month) - 1) * 100, 2) AS percent_growth_from_previous
FROM US_RETAIL_SALES.retail_sales
WHERE kind_of_business = 'Book stores';

-- Year-over-year growth comparison
SELECT sales_year, yearly_sales,
       LAG(yearly_sales) OVER (ORDER BY sales_year ASC) AS prev_year_sales,
       (yearly_sales / LAG(yearly_sales) OVER (ORDER BY sales_year ASC) - 1) * 100 AS percent_growth_from_previous
FROM (
  SELECT EXTRACT(YEAR FROM sales_month) AS sales_year,
         SUM(sales) AS yearly_sales
  FROM US_RETAIL_SALES.retail_sales
  WHERE kind_of_business = 'Book stores'
  GROUP BY 1
)
ORDER BY sales_year;