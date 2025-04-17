create database policy;
use policy;

-- 📊 1. Global Insurance Policies Overview
-- 1.Coverage Distribution by Policy Type
select `policy Type`,sum(`Coverage Amount`) as Total_Coverage
from policy_details
group by `policy type`
order by total_coverage desc;

-- 2.Policy Type Breakdown with Premium Stats
select `policy type`,count(*)
as Policy_Count,round(sum(`premium amount`),0) as Total_Premium
from policy_details
group by `policy Type`
order by Total_Premium desc;
-- 3.Policy Status Overview
select status,count(*) as Total_Policies from policy_details
group by status
order by total_policies;

-- 4.Active vs Expired Policies (Dynamic)
select status,count(*) as Policy_Count from(
select case when `Policy End Date`>=curdate() then 'Active'
else 'Expired' end as status from policy_details) as sub
group by status
order by policy_count desc;

-- 5>Payment Frequency Distribution
select `Payment Frequency`,count(*) as Total_Policies
from policy_details
group by `Payment Frequency`;

-- 6:Policy Insurance Trend Over Time (Monthly)
select DATE_FORMAT(STR_TO_DATE(`Policy Start Date`, '%d-%m-%Y'), '%M') AS Month,
count(*) as Policies_Issued
from policy_details
group by month
order by month;
describe agents;
describe policy_details;
-- 7.Policy Retention Rate Over Time
select 
YEAR(STR_TO_DATE(p.`Policy Start Date`, '%d-%m-%Y'))  as year,
count(*) as policies_ended,
sum(case when a.`Renewal Status`='Renewed' then 1 else 0 end) as renewal_ppolicies,
round(sum(case when a.`Renewal Status`='renewed' then 1 else 0 end)/count(*)*100,2) 
as Retension_Rate from policy_details p join agents a on p.`ï»¿Policy ID`=a.`Policy ID`
group by year
order by year;

-- 8.Average Policy Tenure in Years
SELECT 
  ROUND(AVG(DATEDIFF(STR_TO_DATE(`Policy End Date`, '%d-%m-%Y'),
        STR_TO_DATE(`Policy Start Date`, '%d-%m-%Y')) / 365), 2)
        AS Avg_Tenure_Years FROM policy_details;
-- 9.Total Policies by Year
select year(str_to_date(`Policy Start Date`, '%d-%m-%Y')) as year,
count(*) as Total_Policies
from policy_details
group by year 
order by year;

-- 10 Risk Score Overview by Policy Type
select p.`Policy Type`,
round(avg(a.`Risk Score`),2) as avg_risk_score
from agents a 
join policy_details p on a.`policy id`=p.`ï»¿Policy ID`
group by p.`Policy Type`;

-- 11.Policy Discounts vs Coverage
select
p.`Policy Type`,
round(avg(a.`Policy Discounts`),2) as avg_discount,
round(avg(p.`Coverage Amount`),2) as avg_coverage
from policy_details p
join agents a on a.`policy id`=p.`ï»¿Policy ID`
group by p.`policy type`;

-- 🧑‍💼 2. Customer Demographics
-- 1. top 10 Distribution by City
 describe customers;
 
 select substring_index(`Address (City, State, Zip Code)`,',',1) 
 as city,count(*) as customer_count
 from customers
 group by city
 order by customer_count desc
 limit 10;

-- Distribution by Gender

select gender,count(*) as Total_Customers
from customers
group by gender
order by Total_customers desc;

-- Distribution by Age Group
select AgeGroup,count(*) as Total_customers from customers
group by AgeGroup
order by Total_customers desc;

-- Distribution by Marital Status
select `Marital Status`,count(*) as total_customers from customers
group by `Marital Status`;
describe policy_details;
describe customers;

-- Customer Distribution by Policy Type
select c.agegroup,p.`Policy Type`,count(distinct c.`ï»¿Customer ID`) 
as total_customers from customers c 
join policy_details p on c.`ï»¿Customer ID`=p.`Customer ID`
group by c.AgeGroup,p.`Policy Type`;

-- Top 7 Customers by Total Premium Paid
describe policy_details;
select c.`ï»¿Customer ID`,c.`Name`,sum(p.`Premium Amount`)
as total_premium from customers c
join policy_details p on c.`ï»¿Customer ID`=p.`Customer ID`
group by c.`ï»¿Customer ID`,c.`Name`
order by Total_premium desc
limit 7;

-- Customer Policies Overview
SELECT c.`ï»¿Customer ID`,c.`Name`,
  COUNT(p.`ï»¿Policy ID`) AS Total_Policies,
  SUM(p.`Coverage Amount`) AS Total_Coverage,
  SUM(p.`Premium Amount`) AS Total_Premium FROM customers c
JOIN policy_details p ON c.`ï»¿Customer ID` = p.`Customer ID`
GROUP BY c.`ï»¿Customer ID`, c.`Name`
ORDER BY Total_Policies DESC;
-- Policy Count by Gender
SELECT c.Gender,COUNT(p.`ï»¿Policy ID`) AS Total_Policies
FROM customers c
JOIN policy_details p ON c.`ï»¿Customer ID` = p.`Customer ID`
GROUP BY c.Gender;
describe customers;
describe policy_details;

-- Average Premium by Marital Status
SELECT 
  c.`Marital Status`,
  ROUND(AVG(p.`Premium Amount`), 2) AS Avg_Premium
FROM customers c
JOIN policy_details p ON c.`ï»¿Customer ID` = p.`Customer ID`
GROUP BY c.`Marital Status`;

 -- 🧾 3. Claims Overview
 
 --  1. Claims Distribution by Claim Status
describe claims;
describe customers;
describe policy_details;
 
 select `Claim Status`,count(*) as total_claims from claims
 group by `Claim Status`
 order by total_claims desc;
 
 -- 2 2. Claims by Policy Type
 select p.`policy type`,count(c.`ï»¿Claim ID`) as total_claims
 from claims c 
 join policy_details p on c.`Policy ID`=p.`ï»¿Policy ID`
 group by p.`policy type`
 order by total_claims desc;
 
 -- 3.Claims by Age Group
select cu.agegroup,
count(cl.`ï»¿Claim ID`) as total_claims
from claims cl
join policy_details p on p.`ï»¿Policy ID`=cl.`Policy ID`
join customers cu on p.`customer id`=cu.`ï»¿Customer ID`
group by  cu.agegroup
order by total_claims desc;


 -- Top 7 Customers by Claim Amount
 select cu.`name`,cu.`ï»¿Customer ID`,
 sum(cl.`claim amount`)as total_claim_amount
 from claims cl 
 join policy_details p on cl.`policy id`=p.`ï»¿Policy ID`
 join customers cu on p.`Customer ID`=cu.`ï»¿Customer ID`
 group by cu.`name`,cu.`ï»¿Customer ID`
 order by total_claim_amount desc
 limit 7;
 -- Claim Amount Trend Over Time (Monthly)
SELECT 
  DATE_FORMAT(STR_TO_DATE(`Date of Claim`, '%d-%m-%Y'), '%m') AS Month,
  SUM(`Claim Amount`) AS Total_Claim_Amount
FROM claims
GROUP BY Month
ORDER BY Month;

-- Approved vs. Rejected Claim Ratio
SELECT `Claim Status`,COUNT(*) AS Total
FROM claims
WHERE `Claim Status` IN ('Approved', 'Rejected')
GROUP BY `Claim Status`;
-- Average Claim Amount by Policy Type
select p.`policy type`,round(avg(c.`claim amount`),2) as avg_claim_amount
from claims c join policy_details p on p.`ï»¿Policy ID`=c.`Policy ID`
group by p.`policy type`
order by avg_claim_amount desc;

-- Claim Approval Delay (Avg Days Between Claim and Settlement)

SELECT ROUND(AVG(DATEDIFF(
    STR_TO_DATE(`Settlement Date`, '%d-%m-%Y'),
    STR_TO_DATE(`Date of Claim`, '%d-%m-%Y')
  )), 2) AS Avg_Days_To_Settle
FROM claims
WHERE `Settlement Date` IS NOT NULL;
-- Total Claim Amount by top 10 Reason
select `Reason for Claim`,sum(`claim amount`) 
as total_claim_amount from claims
group by `Reason for Claim`
order by total_claim_amount desc limit 10;

-- Claims Filed per City
SELECT cu.`Address (City, State, Zip Code)` AS City,COUNT(cl.`ï»¿Claim ID`) AS Claim_Count
FROM claims cl
JOIN policy_details p ON cl.`Policy ID` = p.`ï»¿Policy ID`
JOIN customers cu ON p.`Customer ID` = cu.`ï»¿Customer ID`
GROUP BY City
ORDER BY Claim_Count DESC limit 10;

-- 💳 4. Payments & Revenue Overview
describe payments;
-- 1. Total Revenue by payment  Type
select `Payment Method`,
round(sum(`Amount Paid`),2) as total_payments
from payments
group by `payment method`;
-- Total Revenue by Policy Type
SELECT p.`Policy Type`,ROUND(SUM(pay.`Amount Paid`), 2) 
AS Total_Revenue FROM payments pay
JOIN policy_details p ON pay.`Policy ID` = p.`ï»¿Policy ID`
WHERE pay.`Payment Status` = 'Successful'
GROUP BY p.`Policy Type`
ORDER BY Total_Revenue DESC;
describe payments;
select * from payments;
--  Revenue Trend Over Time (Monthly)
SELECT 
  DATE_FORMAT(STR_TO_DATE(`Date of Payment`, '%d-%m-%Y'), '%m') AS Month,
  SUM(`Amount Paid`) AS Monthly_Revenue
FROM payments
WHERE `Payment Status` = 'Successful'
GROUP BY Month
ORDER BY Month;

-- 2. Payment Method Distribution

SELECT `Payment Method`, COUNT(*) AS Total_Transactions
FROM payments
GROUP BY `Payment Method`
ORDER BY Total_Transactions DESC;

-- Total Payments Over Time (Quarterly View)
SELECT CONCAT(YEAR(STR_TO_DATE(`Date of Payment`, '%d-%m-%Y')), '-Q', 
  QUARTER(STR_TO_DATE(`Date of Payment`, '%d-%m-%Y'))) AS Quarter,
  COUNT(*) AS Total_Payments FROM payments
WHERE `Payment Status` = 'successful'
GROUP BY Quarter
ORDER BY Quarter;

-- Sum of Amount Paid by Customer & Payment Status

SELECT cu.`Name`,pay.`Payment Status`,
ROUND(SUM(pay.`Amount Paid`), 2) AS Total_Paid
FROM payments pay
JOIN policy_details p ON pay.`Policy ID` = p.`ï»¿Policy ID`
JOIN customers cu ON p.`Customer ID` = cu.`ï»¿Customer ID`
GROUP BY cu.`Name`, pay.`Payment Status`
ORDER BY Total_Paid DESC;

describe customers;

-- top 10 Average Payment per Policy
SELECT p.`ï»¿Policy ID`,ROUND(AVG(pay.`Amount Paid`), 2) AS Avg_Payment
FROM payments pay
JOIN policy_details p ON pay.`Policy ID` = p.`ï»¿Policy ID`
WHERE pay.`Payment Status` = 'successful'
GROUP BY p.`ï»¿Policy ID`
order by avg_payment desc limit 10;

--  Top 10 Customers by Total Payments
SELECT cu.`Name`,ROUND(SUM(pay.`Amount Paid`), 2) AS Total_Paid
FROM payments pay
JOIN policy_details p ON pay.`Policy ID` = p.`ï»¿Policy ID`
JOIN customers cu ON p.`Customer ID` = cu.`ï»¿Customer ID`
WHERE pay.`Payment Status` = 'successful'
GROUP BY cu.`ï»¿Customer ID`, cu.`Name`
ORDER BY Total_Paid DESC
LIMIT 10;
-- Failed Payments (For Risk Assessment)
SELECT `Payment Method`,COUNT(*) AS Failed_Count
FROM payments
WHERE `Payment Status` = 'Failed'
GROUP BY `Payment Method`
ORDER BY Failed_Count DESC;

-- Policy Payment Frequency Analysis
SELECT 
  `Payment Frequency`,
  COUNT(DISTINCT `ï»¿Policy ID`) AS Policy_Count
FROM policy_details
GROUP BY `Payment Frequency`
ORDER BY Policy_Count DESC;

SELECT 
  YEAR(STR_TO_DATE(`Date of Payment`, '%d-%m-%Y')) AS Year,
  SUM(`Amount Paid`) AS Revenue
FROM payments
WHERE `Payment Status` = 'successful'
GROUP BY Year
ORDER BY Year;
