use r_orders;

DROP VIEW IF exists recency;
DROP VIEW IF exists frequency;
DROP VIEW IF exists monetary;
DROP VIEW IF exists rfm;

CREATE view recency AS 
SELECT cEmailAddress, order_dates,MAX(unix_timestamp(order_dates)) as order_seconds
FROM 
(
select cEmailAddress,  str_to_date(dReceievedDate,'%d/%m/%Y %H:%i') as order_dates 
from orders  where cEmailAddress!="" AND cEmailAddress!='NOT-DISCLOSED-BY-AMAZON' LIMIT 5000
) as smalldatasets -- inner sellect. needs to have its own alias. you can pass the data up to the upper select. eg order_dates
GROUP BY cEmailAddress;
 
CREATE view frequency AS 
SELECT cEmailAddress,SUM(OrderItemQuantity) AS NumOfPurchases
FROM 
(
select cEmailAddress, OrderItemQuantity  from orders  where cEmailAddress!="" AND cEmailAddress!='NOT-DISCLOSED-BY-AMAZON' LIMIT 5000
) as smalldatasets -- inner sellect. needs to have its own alias. you can pass the data up to the upper select. eg order_dates
GROUP BY cEmailAddress;
 
CREATE view monetary AS SELECT 	cEmailAddress, Currency, SUM(Total) AS TotalPurchaseValue
FROM
((select cEmailAddress,(Total/1.5) AS Total,"GBP" AS Currency from orders where Currency="EUR" AND cEmailAddress!="" AND cEmailAddress!='NOT-DISCLOSED-BY-AMAZON'  limit 2500)
UNION ALL
(select cEmailAddress,Total,Currency from orders where Currency="GBP" AND cEmailAddress!="" AND cEmailAddress!='NOT-DISCLOSED-BY-AMAZON' limit 2500)) AS common_currency
GROUP BY cEmailAddress; 

CREATE view rfm AS 
SELECT rf.cEmailAddress,rf.recency,rf.frequency, m.TotalPurchaseValue as monetary FROM
(
SELECT r.cEmailAddress, r.order_dates as recency,f.NumOfPurchases as frequency
FROM recency r INNER JOIN frequency f
    ON r.cEmailAddress = f.cEmailAddress) rf INNER JOIN  monetary m 
    ON rf.cEmailAddress=m.cEmailAddress 
ORDER BY   recency DESC,   frequency DESC,monetary DESC;    
-- ORDER BY   recency DESC,   frequency DESC,monetary DESC LIMIT 10; -- top 10 NEW CUSTOMERS
-- ORDER BY   recency ASC,   frequency ASC,monetary ASC; -- OLD CUSTOMERS
