--Create Table--

CREATE TABLE customer_churn (
    customerid TEXT,
    count INT,
    country TEXT,
    state TEXT,
    city TEXT,
    zip_code INT,
    latitude FLOAT,
    longitude FLOAT,
    gender TEXT,
    senior_citizen TEXT,
    partner TEXT,
    dependents TEXT,
    tenure INT,
    phone_service TEXT,
    multiple_lines TEXT,
    internet_service TEXT,
    online_security TEXT,
    online_backup TEXT,
    device_protection TEXT,
    tech_support TEXT,
    streaming_tv TEXT,
    streaming_movies TEXT,
    contract TEXT,
    paperless_billing TEXT,
    payment_method TEXT,
    monthly_charges TEXT,
    total_charges TEXT,
    churn_label TEXT,
    churn_value INT,
    churn_score INT,
    cltv INT,
    churn_reason TEXT
);


--checking total rows--
SELECT COUNT(*)
FROM customer_churn;


--checking empty values--
SELECT *
FROM customer_churn
WHERE total_charges=''
   OR customerid IS NULL;


--checking duplicate customers--
SELECT customerid, COUNT(*)
FROM customer_churn
GROUP BY customerid
HAVING


--creating clean table--
CREATE TABLE final_customer_churn
AS
SELECT 
customerid,count,country,state,city,
zip_code,
CAST(latitude AS FLOAT)AS latitude,
CAST(longitude AS FLOAT)AS longitude,
gender,senior_citizen,partner,dependents,
CAST(tenure AS INT)AS tenure,
phone_service,multiple_lines,
internet_service,online_security,
online_backup,device_protection,tech_support,
streaming_tv,streaming_movies,contract,
paperless_billing,payment_method, 
CAST(monthly_charges AS FLOAT)AS monthly_charges,
CASE
   WHEN TRIM(total_charges)=''
THEN NULL
     ELSE CAST(total_charges AS FLOAT)
END AS total_charges,
churn_label,
CAST(churn_value AS INT) AS churn_value,
CAST(churn_score AS INT) AS churn_score,
CAST(cltv AS INT) AS cltv,
churn_reason
FROM customer_churn;


--verifying--
SELECT *
FROM customer_churn_cleaned
LIMIT 5;


--SQL KPI ANALYSIS--
--1.Total Customers--
SELECT COUNT(*) AS total_customers
FROM final_customer_churn;


--2.Total churn customer--
SELECT COUNT(*) AS churn_customers
FROM customer_churn
WHERE churn_label='Yes';


--3.Churn Rate%--
SELECT 
ROUND(
100.0*SUM(
CASE WHEN churn_label='Yes' THEN 1
ELSE 0 END 
)/COUNT(*),2
)AS churn_rate_percentage
FROM final_customer_churn;


--Retention Rate%--
SELECT
ROUND(
100.0*SUM(
CASE WHEN churn_label='No' THEN 1
ELSE 0 END 
)/COUNT (*),2
)AS retention_rate
FROM final_customer_churn;


--Monthly Revenue--
SELECT
ROUND(SUM(monthly_charges)::numeric,
2)AS total_monthly_revenue
FROM final_customer_churn;


--Revenue loss due to churn--
SELECT 
ROUND(SUM(monthly_charges)::numeric,
2)AS churn_revenue_loss
FROM final_customer_churn
WHERE churn_label='Yes';


--Average Revenue Per USer--
SELECT 
ROUND(AVG(monthly_charges)::numeric,2)AS
avg_revenue_per_user
FROM customer_churn_cleaned;


--Average Customer Lifetime Value--
SELECT
ROUND(AVG(cltv)::numeric,2) AS 
avg_customer_lifetime_value
FROM final_customer_churn;


--Churn By Contract Type--
SELECT contract, 
COUNT(*) AS total_customers,
SUM(CASE WHEN churn_label='Yes' THEN 
1 ELSE 0 END )AS churn_customers
FROM final_customer_churn
GROUP BY contract
ORDER BY churn_customers DESC;



--Churn By Payment Type--
SELECT payment_method,
COUNT(*) AS total_customers,
SUM(CASE WHEN churn_label='Yes' THEN 
1 ELSE 0 END) AS churn_customers
FROM final_customer_churn
GROUP BY payment_method
ORDER BY churn_customers DESC;



--Churn by internet--
SELECT internet_service,
COUNT(*) AS total_customers,
SUM(CASE WHEN churn_label='Yes' THEN 
1 ELSE 0 END) AS churn_customers
FROM final_customer_churn
GROUP BY internet_service
ORDER BY churn_customers DESC;



--High Revenue Customer at risk--
SELECT 
customerid,monthly_charges,tenure,contract
FROM final_customer_churn
WHERE churn_label='Yes'
AND monthly_charges > (
SELECT AVG(monthly_charges)
FROM final_customer_churn
)
ORDER BY monthly_charges DESC;



--Senior citizen churn analysis--
SELECT 
senior_citizen,
COUNT(*) AS total_customers,
SUM(CASE WHEN churn_label='Yes'THEN 
1 ELSE 0 END ) AS churn_customers
FROM final_customer_churn
GROUP BY senior_citizen;



--Tenure based churn--
SELECT 
CASE 
WHEN tenure<=12 THEN '0-1 Year'
WHEN tenure<=24 THEN '1-2 Years'
WHEN tenure<=48 THEN '2-4 Years'
ELSE '4+ Years'
END AS tenure_group,
COUNT(*) AS total_customers,
SUM(CASE WHEN churn_label='Yes' THEN
1 ELSE 0 END )AS churn_customers
FROM final_customer_churn
GROUP BY tenure_group
ORDER BY churn_customers DESC;


--Top churn reasons--
SELECT 
churn_reason,
COUNT(*) AS total_churn
FROM final_customer_churn
WHERE churn_label='Yes'
GROUP BY churn_reason
ORDER BY total_churn DESC;