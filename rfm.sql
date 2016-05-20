/*
START RFM
*/

/*
RECENCY
*/
SELECT   cFullName, Country, dReceievedDate AS OrderDate
FROM orders
GROUP BY cEmailAddress
ORDER BY dReceievedDate DESC
LIMIT 10;



/*
FREQUENCY
*/
SELECT  count(cEmailAddress) AS NumOfCustPurchases, cFullName, Country, dReceievedDate AS OrderDate
FROM orders
group by cFullName
ORDER BY NumOfCustPurchases DESC
LIMIT 10;



/*
MONETARY
*/
SELECT   cFullName, Country, dReceievedDate AS OrderDate, Total AS TotalAmtSpent
FROM orders
ORDER BY TotalAmtSpent DESC
LIMIT 10;
