-- 1. Display all invoices
SELECT *
FROM invoice;

-- 2. Display customer, invoice amount and invoice date
SELECT customerid, total, invoicedate
FROM invoice;

SELECT *
FROM invoice
WHERE total > (
    SELECT AVG(total)
    FROM invoice
);

SELECT *
FROM invoice AS i
WHERE total > (
    SELECT AVG(i2.total)
    FROM invoice AS i2
    WHERE i2.billingcountry = i.billingcountry
);


SELECT *
FROM invoice AS i
WHERE total > (
    SELECT AVG(i2.total)
    FROM invoice AS i2
    WHERE i2.customerid = i.customerid
);

SELECT c.customerid
FROM customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM invoice AS i
    WHERE c.customerid = i.customerid
);

SELECT a.artistid, a.artistname
FROM artist AS a
WHERE EXISTS (
    SELECT 1
    FROM album AS al
    WHERE a.artistid = al.artistid
);

SELECT 
    customerid,
    AVG(total) AS average_invoice
FROM invoice
GROUP BY customerid
ORDER BY average_invoice DESC;

SELECT 
    billingcountry,
    SUM(total) AS total_sales,
    COUNT(total) AS invoice_count,
    AVG(total) AS average_invoice
FROM invoice
GROUP BY billingcountry;

SELECT 
    firstname,
    COUNT(*) AS customer_count
FROM customer
GROUP BY firstname
HAVING COUNT(*) > 1;


SELECT 
    e.empid,
    e.firstname,
    e.lastname,
    COUNT(c.customerid) AS customer_count
FROM emp AS e
LEFT JOIN customer AS c
    ON c.supportrepid = e.empid
GROUP BY e.empid, e.firstname, e.lastname;

SELECT 
    c.customerid,
    c.firstname,
    c.lastname
FROM customer AS c
LEFT JOIN invoice AS i
    ON c.customerid = i.customerid
WHERE i.invoiceid IS NULL;

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


SELECT 
    empid,
    title
FROM emp
WHERE reportsto IS NULL;

SELECT 
    empid,
    title,
    COALESCE(reportsto, 0) AS manager_id
FROM emp;

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


	SELECT 
    customerid,
    total,
    invoicedate
FROM invoice
WHERE EXTRACT(MONTH FROM invoicedate) = 2;


SELECT 
    customerid,
    total,
    invoicedate
FROM invoice
WHERE invoicedate > '2026-01-08'
  AND invoicedate < '2026-02-20';

  SELECT 
    DATE_TRUNC('month', invoicedate) AS invoice_month,
    SUM(total) AS monthly_sales
FROM invoice
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY invoice_month DESC;

SELECT 
    DATE_TRUNC('month', invoicedate) AS invoice_month,
    COUNT(*) AS invoice_count
FROM invoice
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY invoice_month;


SELECT 
    firstname,
    lastname,
    CONCAT(firstname, ' ', lastname) AS full_name
FROM customer;


SELECT 
    firstname,
    lastname
FROM customer
WHERE firstname LIKE 'A%';

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


SELECT 
    customerid,
    total,
    AVG(total) OVER (
        PARTITION BY customerid
    ) AS customer_average_invoice
FROM invoice;


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


SELECT 
    customerid,
    firstname,
    lastname,
    ROW_NUMBER() OVER (
        PARTITION BY lastname
        ORDER BY customerid
    ) AS row_number
FROM customer;

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


SELECT 
    e1.empid,
    e1.firstname AS employee_firstname,
    e1.lastname AS employee_lastname,
    e2.firstname AS manager_firstname,
    e2.lastname AS manager_lastname,
    e1.employee_salary,
    e2.manager_salary,
    COALESCE(
        e2.manager_salary - e1.employee_salary,
        0
    ) AS salary_difference
FROM emp AS e1
INNER JOIN emp AS e2
    ON e1.reportsto = e2.empid;


	