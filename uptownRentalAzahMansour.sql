-- Azah Mansour, Bus440 Project 1, 03/28/2025

USE Uptown;

-- A) What is the list of all instrument rentals in inventory? (show the list displayed in figure 1, along with any other rentals in your database)
SELECT instrument.serialnumber AS 'Serial Num', customername AS 'Customer Name', rental.rentaldate AS 'Rental Date', 
instrument.instrumenttype AS 'Instrument Type', rentaltier AS 'Rental Tier', contactemail AS 'Contact Email', staffname AS 'Staff Name',
 rental.returndate AS 'Return Date', rental.duedate AS 'Due Date', instrument.dailyrentalfee AS 'Daily Rental Fee',
 fine.dailyoverduefee AS 'Daily Overdue Fee'
FROM instrument INNER JOIN RENTAL ON instrument.serialnumber = rental.serialnumber
INNER JOIN customer ON customer.customerID = rental.customerID
INNER JOIN staff ON staff.staffID = rental.staffID
INNER JOIN fine ON fine.fineID = rental.fineID;

-- B) What are the youngest and oldest customers of Uptown Rentals? Write one SQL program to display both
SELECT MAX(customerage) AS 'oldest', MIN(customerage) AS 'youngest'
FROM customer;

-- C) List the aggregated (summed) rental amounts per customer. Sequence result to show customer w/ highest rental amount first
SELECT customer.customerID, customername AS 'customer', SUM((dailyrentalfee * (DATEDIFF(returndate, rentaldate)))) AS 'rental amount'
FROM rental INNER JOIN customer ON rental.customerID = customer.customerID 
INNER JOIN instrument ON rental.serialnumber = instrument.serialnumber
GROUP BY customer.customerID, customername
ORDER BY SUM((dailyrentalfee * (DATEDIFF(returndate, rentaldate)))) DESC;

-- D) Which customer has the most rentals (highest count) across all time?
SELECT customername, COUNT(rental.customerID)
FROM customer INNER JOIN rental ON customer.customerID = Rental.customerID
GROUP BY customername
ORDER BY COUNT(customer.customerID) DESC
LIMIT 2; -- 2 customers have the highest count


-- E) Which customer had the most rentals in January 2025, and what was their average rental total per rental?
SELECT customername AS 'Customer Name', COUNT(rental.rentalID) AS 'total rentals', AVG((instrument.dailyrentalfee * (DATEDIFF(returndate, rentaldate)))+ 
(dayslate * dailyoverduefee))
AS 'AVG rental total'
FROM customer JOIN rental ON customer.customerID = rental.customerID
JOIN fine ON rental.fineID = fine.fineID
JOIN instrument ON instrument.serialnumber = rental.serialnumber
WHERE rentaldate LIKE '2025-01%'
GROUP BY customername
ORDER BY COUNT(rental.rentalID) DESC
LIMIT 2; -- Ric & Lauren has the most rentals in January 2025



-- F) Which staff member (name) is associated w/ the most rentals in january 2025?
SELECT staffname, COUNT(rental.staffID), rentaldate
FROM staff INNER JOIN rental ON staff.staffID = rental.staffID
WHERE rentaldate >= '2025-01-01' AND returndate <'2025-02-01'
GROUP BY staffname, rentaldate
ORDER BY COUNT(staffID) DESC
LIMIT 1;

-- G) For each customer that has an overdue rental, how many days have passed since the rental was due?
SELECT customername AS 'Customer Name', dayslate AS 'Days late'
FROM customer INNER JOIN rental ON customer.customerID = rental.customerID INNER JOIN fine ON rental.fineID = fine.fineID
WHERE dayslate > 0
GROUP BY customername, dayslate;


-- H) What is the total rental amount by rental tier?
SELECT rentaltier AS 'Rental Tier', SUM((instrument.dailyrentalfee * (DATEDIFF(returndate, rentaldate))) + (dayslate * dailyoverduefee)) AS 'Total rental amount'
FROM instrument INNER JOIN rental ON instrument.serialnumber = rental.serialnumber INNER JOIN fine ON rental.fineID = fine.fineID
GROUP BY rentaltier
ORDER BY SUM((instrument.dailyrentalfee * (DATEDIFF(returndate, rentaldate))) + (dayslate * dailyoverduefee));


-- I) who are the top 3 store staff members in terms of total rental amounts?
SELECT staffname AS 'Staff Name', COUNT(rentalID) AS 'Total Rental Amounts'
FROM staff INNER JOIN rental ON staff.staffID = rental.staffID
GROUP BY staffname
ORDER BY COUNT(rentalID) DESC
LIMIT 3;

-- J) What is the total rental amount by instrument type, where the instrument type is Flute or Bass Guitar?
SELECT instrumenttype AS 'Instrument Type', SUM((instrument.dailyrentalfee * (DATEDIFF(returndate, rentaldate))) + (dayslate * dailyoverduefee)) AS 'Total Rental Amount'
FROM instrument INNER JOIN rental ON instrument.serialnumber = rental.serialnumber INNER JOIN fine ON rental.fineID = fine.fineID
WHERE instrumenttype = 'Flute' OR instrumenttype= 'Bass Guitar'
GROUP BY instrumenttype
ORDER BY SUM((instrument.dailyrentalfee * (DATEDIFF(returndate, rentaldate))) + (dayslate * dailyoverduefee));


-- K) What is the name of any customer who has 2 or more overdue rentals?
SELECT customername AS 'Customer Name', COUNT(dayslate) AS 'Number of overdue rentals'
FROM customer INNER JOIN rental ON customer.customerID = rental.customerID INNER JOIN fine ON rental.fineID = fine.fineID
GROUP BY customername
HAVING COUNT(dayslate) >= 2
ORDER BY COUNT(dayslate);

-- L) List all of the instruments in inventory in 2025 that were damaged upon return or needed maintenance. include employee, repair cost, & maintenance date
SELECT instrument.serialnumber AS 'Serial Num', instrumenttype AS 'Instrument Type', staffname AS 'Staff Name', repairissue AS 'Repair Issue',
 repaircost AS 'Repair Cost', maintenancedate AS 'Maintenance Date'
FROM maintenance INNER JOIN staff ON maintenance.staffID = staff.staffID INNER JOIN instrument ON maintenance.serialnumber = instrument.serialnumber
WHERE maintenancedate >= '2025-01-01' AND maintenancedate <= '2025-12-31';



-- M) What is the average rental period for the basic rental tier?
SELECT AVG((DATEDIFF(returndate, rentaldate))) AS 'AVG rental period (Days)'
FROM rental
WHERE rental.serialnumber IN (SELECT serialnumber FROM instrument WHERE rentaltier = 'Basic');


-- N) What is Uptown rental's total revenue generated?
SELECT (SUM((instrument.dailyrentalfee * (DATEDIFF(returndate, rentaldate))) + (dayslate * dailyoverduefee)) - SUM(repaircost) )AS 'Total Revenue'
FROM instrument INNER JOIN rental ON instrument.serialnumber = rental.serialnumber INNER JOIN fine ON rental.fineID = fine.fineID 
INNER JOIN maintenance ON maintenance.serialnumber = instrument.serialnumber;



