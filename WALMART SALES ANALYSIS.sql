use sales

select * from sales.walmart

--Data cleaning
CREATE TABLE sales.walmart_sales AS 
SELECT * FROM sales.walmart;

--remove duplictes
CREATE TABLE sales.walmart_sales1 AS
SELECT * FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY Weekly_Sales,Temperature,Fuel_Price,CPI,Unemployment ORDER BY Weekly_Sales,Temperature,Fuel_Price,CPI,Unemployment) AS row_num
  FROM sales.walmart_sales
) AS numbered_rows
WHERE row_num = 1;
SET SQL_SAFE_UPDATES = 0;
 
DELETE FROM sales.walmart_sales;
SET SQL_SAFE_UPDATES = 1;

INSERT INTO sales.walmart_sales (`Store`, `Date`, `Weekly_Sales`, `Holiday_Flag`, `Temperature`, `Fuel_Price`, `CPI`, `Unemployment`)
SELECT `Store`, `Date`, `Weekly_Sales`, `Holiday_Flag`, `Temperature`, `Fuel_Price`, `CPI`, `Unemployment`
FROM sales.walmart_sales1;

DROP TABLE sales.walmart_sales1;


select * from sales.walmart_sales

SELECT *
FROM walmart_sales
ORDER BY Store;




SET SQL_SAFE_UPDATES = 0;
UPDATE walmart_sales
SET Weekly_Sales = ROUND(Weekly_Sales);

SET SQL_SAFE_UPDATES = 1;


ALTER TABLE walmart_sales
ADD COLUMN Day_Type VARCHAR(20);


UPDATE walmart_sales
SET Day_Type = CASE
    WHEN Holiday_Flag = 1 THEN 'Holiday'
    ELSE 'Working day'
END;

UPDATE walmart_sales
SET CPI = ROUND(CPI, 2);

ALTER TABLE walmart_sales
DROP COLUMN Holiday_Flag;

--Data Analysis

==Total sales
SELECT 
    SUM(Weekly_Sales) AS Total_Sales
FROM 
    walmart_sales;
    
==Correlation of Sales and Temperature

SELECT 
    ROUND(
        (
            (COUNT(*) * SUM(Temperature * Weekly_Sales) - SUM(Temperature) * SUM(Weekly_Sales)) / 
            (SQRT((COUNT(*) * SUM(Temperature * Temperature) - POWER(SUM(Temperature), 2)) * 
                  (COUNT(*) * SUM(Weekly_Sales * Weekly_Sales) - POWER(SUM(Weekly_Sales), 2))))
        ), 
        4
    ) AS Correlation_Coefficient
FROM 
    walmart_sales;
    
==Fuel Price and Sales
SELECT 
    ROUND(
        (
            (COUNT(*) * SUM(Fuel_Price * Weekly_Sales) - SUM(Fuel_Price) * SUM(Weekly_Sales)) / 
            (SQRT((COUNT(*) * SUM(Fuel_Price * Fuel_Price) - POWER(SUM(Fuel_Price), 2)) * 
                  (COUNT(*) * SUM(Weekly_Sales * Weekly_Sales) - POWER(SUM(Weekly_Sales), 2))))
        ), 
        4
    ) AS Correlation_Coefficient
FROM 
    walmart_sales;
    
==CPI and Sales

SELECT 
    ROUND(
        (
            (COUNT(*) * SUM(CPI * Weekly_Sales) - SUM(CPI) * SUM(Weekly_Sales)) / 
            (SQRT((COUNT(*) * SUM(CPI * CPI) - POWER(SUM(CPI), 2)) * 
                  (COUNT(*) * SUM(Weekly_Sales * Weekly_Sales) - POWER(SUM(Weekly_Sales), 2))))
        ), 
        4
    ) AS Correlation_Coefficient
FROM 
    walmart_sales;
    
==Unemployment

SELECT 
    ROUND(
        (
            (COUNT(*) * SUM(Unemployment * Weekly_Sales) - SUM(Unemployment) * SUM(Weekly_Sales)) / 
            (SQRT((COUNT(*) * SUM(Unemployment * Unemployment) - POWER(SUM(Unemployment), 2)) * 
                  (COUNT(*) * SUM(Weekly_Sales * Weekly_Sales) - POWER(SUM(Weekly_Sales), 2))))
        ), 
        4
    ) AS Correlation_Coefficient
FROM 
    walmart_sales;
    
==Holiday

SELECT
    Day_Type,
    AVG(Weekly_Sales) AS Average_Sales
FROM
    walmart_sales
GROUP BY
    Day_Type;
    
WITH sales_comparison AS (
    SELECT
        Day_Type,
        AVG(Weekly_Sales) AS Average_Sales
    FROM
        walmart_sales
    GROUP BY
        Day_Type
)

SELECT
    MAX(CASE WHEN Day_Type = 'Holiday' THEN Average_Sales ELSE NULL END) -
    MAX(CASE WHEN Day_Type = 'Working day' THEN Average_Sales ELSE NULL END) AS Sales_Difference,
    (MAX(CASE WHEN Day_Type = 'Holiday' THEN Average_Sales ELSE NULL END) -
     MAX(CASE WHEN Day_Type = 'Working day' THEN Average_Sales ELSE NULL END)) /
    MAX(CASE WHEN Day_Type = 'Working day' THEN Average_Sales ELSE NULL END) * 100 AS Sales_Growth_Rate
FROM
    sales_comparison;

==Store level Comparison



SELECT
    VAR_SAMP(Weekly_Sales) AS Overall_Sales_Variance
FROM
    walmart_sales;
    
==High performing Store
SELECT 
    Store, 
    AVG(Weekly_Sales) AS Avg_Weekly_Sales
FROM 
    walmart_sales
GROUP BY 
    Store
ORDER BY 
    Avg_Weekly_Sales DESC
LIMIT 1;  

==Low performing store
SELECT 
    Store, 
    AVG(Weekly_Sales) AS Avg_Weekly_Sales
FROM 
    walmart_sales
GROUP BY 
    Store
ORDER BY 
    Avg_Weekly_Sales ASC
LIMIT 1;


