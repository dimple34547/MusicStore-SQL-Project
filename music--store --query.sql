/* ============================================================
   SQL QUERY PRACTICE PROJECT
   Database: Music Store Database
   ============================================================ */


/* ============================================================
   1. DISPLAY ALL INVOICES
   Concept: SELECT
   Output: Displays all columns and all records from invoice.
   ============================================================ */

SELECT *
FROM invoice;


/* ============================================================
   2. DISPLAY CUSTOMER, INVOICE AMOUNT AND INVOICE DATE
   Concept: SELECT
   Output: Displays customer ID, invoice amount and invoice date.
   ============================================================ */

SELECT customerid, total, invoicedate
FROM invoice;


/* ============================================================
   3. INVOICES ABOVE THE OVERALL AVERAGE
   Concept: Subquery, AVG()
   Output: Displays invoices whose amount is greater than
           the average invoice amount of all invoices.
   ============================================================ */

SELECT *
FROM invoice
WHERE total > (
    SELECT AVG(total)
    FROM invoice
);


/* ============================================================
   4. INVOICES ABOVE THE AVERAGE OF THEIR BILLING COUNTRY
   Concept: Correlated Subquery, AVG()
   Output: Displays invoices whose amount is greater than the
           average invoice amount of their billing country.
   ============================================================ */

SELECT *
FROM invoice AS i
WHERE total > (
    SELECT AVG(i2.total)
    FROM invoice AS i2
    WHERE i2.billingcountry = i.billingcountry
);


/* ============================================================
   5. INVOICES ABOVE THE CUSTOMER'S AVERAGE
   Concept: Correlated Subquery, AVG()
   Output: Displays invoices whose amount is greater than
           that customer's average invoice amount.
   ============================================================ */

SELECT *
FROM invoice AS i
WHERE total > (
    SELECT AVG(i2.total)
    FROM invoice AS i2
    WHERE i2.customerid = i.customerid
);


/* ============================================================
   6. CUSTOMERS WHO HAVE NEVER MADE AN INVOICE
   Concept: NOT EXISTS, Subquery
   Output: Displays customers who do not have any invoice.
   ============================================================ */

SELECT c.customerid
FROM customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM invoice AS i
    WHERE c.customerid = i.customerid
);


/* ============================================================
   7. ARTISTS WHO HAVE AT LEAST ONE ALBUM
   Concept: EXISTS, Subquery
   Output: Displays artists who have at least one album.
   ============================================================ */

SELECT a.artistid, a.artistname
FROM artist AS a
WHERE EXISTS (
    SELECT 1
    FROM album AS al
    WHERE a.artistid = al.artistid
);


/* ============================================================
   8. AVERAGE INVOICE AMOUNT PER CUSTOMER
   Concept: AVG(), GROUP BY, ORDER BY
   Output: Displays each customer's average invoice amount
           from highest to lowest.
   ============================================================ */

SELECT
    customerid,
    AVG(total) AS average_invoice
FROM invoice
GROUP BY customerid
ORDER BY average_invoice DESC;


/* ============================================================
   9. SALES SUMMARY BY COUNTRY
   Concept: SUM(), COUNT(), AVG(), GROUP BY
   Output: Displays total sales, invoice count and average
           invoice amount for each country.
   ============================================================ */

SELECT
    billingcountry,
    SUM(total) AS total_sales,
    COUNT(total) AS invoice_count,
    AVG(total) AS average_invoice
FROM invoice
GROUP BY billingcountry;


/* ============================================================
   10. DUPLICATE CUSTOMER FIRST NAMES
   Concept: COUNT(), GROUP BY, HAVING
   Output: Displays first names that appear more than once.
   ============================================================ */

SELECT
    firstname,
    COUNT(*) AS customer_count
FROM customer
GROUP BY firstname
HAVING COUNT(*) > 1;


/* ============================================================
   11. NUMBER OF CUSTOMERS ASSIGNED TO EACH EMPLOYEE
   Concept: LEFT JOIN, COUNT(), GROUP BY
   Output: Displays every employee and the number of customers
           assigned to them.
   ============================================================ */

SELECT
    e.empid,
    e.firstname,
    e.lastname,
    COUNT(c.customerid) AS customer_count
FROM emp AS e
LEFT JOIN customer AS c
    ON c.supportrepid = e.empid
GROUP BY e.empid, e.firstname, e.lastname;


/* ============================================================
   12. CUSTOMERS WHO HAVE NO INVOICES
   Concept: LEFT JOIN, IS NULL
   Output: Displays customers who have never generated
           an invoice.
   ============================================================ */

SELECT
    c.customerid,
    c.firstname,
    c.lastname
FROM customer AS c
LEFT JOIN invoice AS i
    ON c.customerid = i.customerid
WHERE i.invoiceid IS NULL;


/* ============================================================
   13. TOTAL TRACKS PER ARTIST
   Concept: INNER JOIN, COUNT(), GROUP BY
   Output: Displays each artist and their total number of tracks.
   ============================================================ */

SELECT
    a.artistid,
    a.artistname,
    COUNT(t.trackid) AS total_tracks
FROM artist AS a
INNER JOIN album AS al
    ON a.artistid = al.artistid
INNER JOIN track AS t
    ON al.albumid = t.albumid
GROUP BY a.artistid, a.artistname;


/* ============================================================
   14. ARTIST WITH THE HIGHEST NUMBER OF TRACKS
   Concept: INNER JOIN, COUNT(), GROUP BY, ORDER BY, LIMIT
   Output: Displays the artist with the highest number of tracks.
   ============================================================ */

SELECT
    a.artistid,
    a.artistname,
    COUNT(t.trackid) AS total_tracks
FROM artist AS a
INNER JOIN album AS al
    ON a.artistid = al.artistid
INNER JOIN track AS t
    ON al.albumid = t.albumid
GROUP BY a.artistid, a.artistname
ORDER BY total_tracks DESC
LIMIT 1;


/* ============================================================
   15. EMPLOYEES WHO DO NOT REPORT TO A MANAGER
   Concept: IS NULL
   Output: Displays employees who do not have a manager.
   ============================================================ */

SELECT
    empid,
    title
FROM emp
WHERE reportsto IS NULL;


/* ============================================================
   16. REPLACE NULL MANAGER ID WITH 0
   Concept: COALESCE()
   Output: Replaces NULL manager IDs with 0.
   ============================================================ */

SELECT
    empid,
    title,
    COALESCE(reportsto, 0) AS manager_id
FROM emp;


/* ============================================================
   17. EMPLOYEE VS MANAGER SALARY
   Concept: SELF JOIN, INNER JOIN, COALESCE()
   Output: Displays employee salary, manager salary and
           salary difference.
   ============================================================ */

SELECT
    e1.empid,
    e1.firstname AS employee_firstname,
    e1.lastname AS employee_lastname,
    e2.firstname AS manager_firstname,
    e2.lastname AS manager_lastname,
    e1.salaryofemp AS employee_salary,
    e2.salaryofmanager AS manager_salary,
    COALESCE(
        e2.salaryofmanager - e1.salaryofemp,
        0
    ) AS salary_difference
FROM emp AS e1
INNER JOIN emp AS e2
    ON e1.reportsto = e2.empid;


/* ============================================================
   18. INVOICES FROM FEBRUARY
   Concept: EXTRACT(), WHERE
   Output: Displays invoices generated in February.
   ============================================================ */

SELECT
    customerid,
    total,
    invoicedate
FROM invoice
WHERE EXTRACT(MONTH FROM invoicedate) = 2;


/* ============================================================
   19. INVOICES BETWEEN TWO DATES
   Concept: WHERE, Comparison Operators
   Output: Displays invoices between January 8 and
           February 20, 2026.
   ============================================================ */

SELECT
    customerid,
    total,
    invoicedate
FROM invoice
WHERE invoicedate > '2026-01-08'
  AND invoicedate < '2026-02-20';


/* ============================================================
   20. MONTHLY SALES
   Concept: DATE_TRUNC(), SUM(), GROUP BY, ORDER BY
   Output: Displays total sales for each month.
   ============================================================ */

SELECT
    DATE_TRUNC('month', invoicedate) AS invoice_month,
    SUM(total) AS monthly_sales
FROM invoice
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY invoice_month DESC;


/* ============================================================
   21. NUMBER OF INVOICES PER MONTH
   Concept: DATE_TRUNC(), COUNT(), GROUP BY
   Output: Displays the number of invoices generated each month.
   ============================================================ */

SELECT
    DATE_TRUNC('month', invoicedate) AS invoice_month,
    COUNT(*) AS invoice_count
FROM invoice
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY invoice_month;


/* ============================================================
   22. CREATE FULL CUSTOMER NAME
   Concept: CONCAT()
   Output: Combines first name and last name into full name.
   ============================================================ */

SELECT
    firstname,
    lastname,
    CONCAT(firstname, ' ', lastname) AS full_name
FROM customer;


/* ============================================================
   23. CUSTOMERS WHOSE FIRST NAME STARTS WITH A
   Concept: LIKE, Wildcard %
   Output: Displays customers whose first name starts with A.
   ============================================================ */

SELECT
    firstname,
    lastname
FROM customer
WHERE firstname LIKE 'A%';


/* ============================================================
   24. TOTAL INVOICE AMOUNT ABOVE AND BELOW 2
   Concept: CASE, SUM(), INNER JOIN, GROUP BY
   Output: Displays each customer's total invoice amount
           above 2 and below 2.
   ============================================================ */

SELECT
    c.firstname,
    c.lastname,

    SUM(
        CASE
            WHEN i.total > 2 THEN i.total
            ELSE 0
        END
    ) AS total_above_2,

    SUM(
        CASE
            WHEN i.total < 2 THEN i.total
            ELSE 0
        END
    ) AS total_below_2

FROM customer AS c
INNER JOIN invoice AS i
    ON c.customerid = i.customerid
GROUP BY c.firstname, c.lastname;


/* ============================================================
   25. AVERAGE INVOICE AMOUNT FOR EACH CUSTOMER
   Concept: Window Function, AVG() OVER(), PARTITION BY
   Output: Displays each invoice along with that customer's
           average invoice amount.
   ============================================================ */

SELECT
    customerid,
    total,
    AVG(total) OVER (
        PARTITION BY customerid
    ) AS customer_average_invoice
FROM invoice;


/* ============================================================
   26. CUSTOMER DETAILS WITH AVERAGE INVOICE
   Concept: INNER JOIN, Window Function, AVG(), PARTITION BY
   Output: Displays customer details, invoice amount and
           customer average invoice amount.
   ============================================================ */

SELECT
    c.customerid,
    c.firstname,
    c.lastname,
    i.total,
    AVG(i.total) OVER (
        PARTITION BY c.customerid
    ) AS customer_average_invoice
FROM customer AS c
INNER JOIN invoice AS i
    ON c.customerid = i.customerid;


/* ============================================================
   27. CUSTOMER TOTAL SPEND AND OVERALL SALES
   Concept: SUM(), COUNT(), Window Function, SUM() OVER()
   Output: Displays customer total spending, invoice count
           and overall sales.
   ============================================================ */

SELECT
    c.firstname,
    c.lastname,
    SUM(i.total) AS total_spend,
    COUNT(i.invoiceid) AS invoice_count,
    SUM(SUM(i.total)) OVER () AS overall_sales
FROM customer AS c
INNER JOIN invoice AS i
    ON c.customerid = i.customerid
GROUP BY c.firstname, c.lastname
ORDER BY total_spend DESC, invoice_count DESC;


/* ============================================================
   28. PREVIOUS INVOICE AMOUNT
   Concept: LAG(), Window Function, PARTITION BY, ORDER BY
   Output: Displays the previous invoice amount for each customer.
   ============================================================ */

SELECT
    c.customerid,
    c.firstname,
    c.lastname,
    i.total,
    i.invoicedate,
    LAG(i.total) OVER (
        PARTITION BY c.customerid
        ORDER BY i.invoicedate
    ) AS previous_invoice_amount
FROM customer AS c
INNER JOIN invoice AS i
    ON c.customerid = i.customerid
ORDER BY c.customerid, i.invoicedate;


/* ============================================================
   29. ROW NUMBER WITHIN EACH LAST NAME
   Concept: ROW_NUMBER(), Window Function, PARTITION BY
   Output: Assigns a sequential row number to customers
           within each last name.
   ============================================================ */

SELECT
    customerid,
    firstname,
    lastname,
    ROW_NUMBER() OVER (
        PARTITION BY lastname
        ORDER BY customerid
    ) AS row_number
FROM customer;


/* ============================================================
   30. RANK CUSTOMERS BY TOTAL SPENDING
   Concept: CTE, SUM(), RANK(), Window Function
   Output: Ranks customers according to their total spending.
   ============================================================ */

WITH customer_spending AS (
    SELECT
        c.customerid,
        c.firstname,
        c.lastname,
        SUM(i.total) AS total_spend
    FROM customer AS c
    INNER JOIN invoice AS i
        ON c.customerid = i.customerid
    GROUP BY c.customerid, c.firstname, c.lastname
)

SELECT
    customerid,
    firstname,
    lastname,
    total_spend,
    RANK() OVER (
        ORDER BY total_spend DESC
    ) AS customer_rank
FROM customer_spending
ORDER BY customer_rank;


/* ============================================================
   31. TOP 7 CUSTOMERS BY TOTAL SPENDING
   Concept: CTE, RANK(), Window Function
   Output: Displays customers whose rank is 7 or better.
   ============================================================ */

WITH customer_spending AS (
    SELECT
        c.customerid,
        c.firstname,
        c.lastname,
        SUM(i.total) AS total_spend
    FROM customer AS c
    INNER JOIN invoice AS i
        ON c.customerid = i.customerid
    GROUP BY c.customerid, c.firstname, c.lastname
),

ranked_customers AS (
    SELECT
        customerid,
        firstname,
        lastname,
        total_spend,
        RANK() OVER (
            ORDER BY total_spend DESC
        ) AS customer_rank
    FROM customer_spending
)

SELECT
    customerid,
    firstname,
    lastname,
    total_spend,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 7
ORDER BY customer_rank;


/* ============================================================
   32. CUSTOMERS SPENDING ABOVE THE OVERALL AVERAGE
   Concept: CTE, AVG() OVER(), Window Function
   Output: Displays customers whose total spending is greater
           than the average spending of all customers.
   ============================================================ */

WITH customer_spending AS (
    SELECT
        c.customerid,
        c.firstname,
        c.lastname,
        SUM(i.total) AS total_spend
    FROM customer AS c
    INNER JOIN invoice AS i
        ON c.customerid = i.customerid
    GROUP BY c.customerid, c.firstname, c.lastname
),

customer_average AS (
    SELECT
        customerid,
        firstname,
        lastname,
        total_spend,
        AVG(total_spend) OVER () AS overall_average_spend
    FROM customer_spending
)

SELECT
    customerid,
    firstname,
    lastname,
    total_spend,
    overall_average_spend
FROM customer_average
WHERE total_spend > overall_average_spend
ORDER BY total_spend DESC;


/* ============================================================
   33. SECOND HIGHEST INVOICE AMOUNT
   Concept: CTE, DENSE_RANK(), Window Function
   Output: Displays invoices having the second-highest
           distinct invoice amount.
   ============================================================ */

WITH ranked_invoices AS (
    SELECT
        i.invoiceid,
        c.customerid,
        c.firstname,
        c.lastname,
        i.total,

        DENSE_RANK() OVER (
            ORDER BY i.total DESC
        ) AS invoice_rank

    FROM customer AS c
    INNER JOIN invoice AS i
        ON c.customerid = i.customerid
)

SELECT
    invoiceid,
    customerid,
    firstname,
    lastname,
    total,
    invoice_rank
FROM ranked_invoices
WHERE invoice_rank = 2;


/* ============================================================
   34. EMPLOYEE AND MANAGER SALARY COMPARISON
   Concept: SELF JOIN, INNER JOIN, COALESCE()
   Output: Displays employee salary, manager salary and
           salary difference.
   ============================================================ */

SELECT
    e1.empid,
    e1.firstname AS employee_firstname,
    e1.lastname AS employee_lastname,
    e2.firstname AS manager_firstname,
    e2.lastname AS manager_lastname,
    e1.salaryofemp AS employee_salary,
    e2.salaryofmanager AS manager_salary,
    COALESCE(
        e2.salaryofmanager - e1.salaryofemp,
        0
    ) AS salary_difference
FROM emp AS e1
INNER JOIN emp AS e2
    ON e1.reportsto = e2.empid;
