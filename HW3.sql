create database assignment3; -- creates the database holding all necessary tables

-- adding primary key constraints to each table
ALTER TABLE merchants ADD CONSTRAINT pk_merchants PRIMARY KEY (mid);
ALTER TABLE products ADD CONSTRAINT pk_products PRIMARY KEY (pid);
ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY (oid);
ALTER TABLE contain ADD CONSTRAINT pk_contain PRIMARY KEY (oid, pid);
ALTER TABLE customers ADD CONSTRAINT pk_customers PRIMARY KEY (cid);
ALTER TABLE place ADD CONSTRAINT pk_place PRIMARY KEY (cid, oid);
ALTER TABLE sell add constraint fk_sell Primary Key (mid, pid);

-- adding foreign key constraints to each relation table
ALTER TABLE sell ADD CONSTRAINT fk_sell_mid FOREIGN KEY (mid) REFERENCES merchants(mid);
ALTER TABLE sell ADD CONSTRAINT fk_sell_pid FOREIGN KEY (pid) REFERENCES products(pid);
ALTER TABLE contain ADD CONSTRAINT fk_contain_oid FOREIGN KEY (oid) REFERENCES orders(oid);
ALTER TABLE contain ADD CONSTRAINT fk_contain_pid FOREIGN KEY (pid) REFERENCES products(pid);
ALTER TABLE place ADD CONSTRAINT fk_place_cid FOREIGN KEY (cid) REFERENCES customers(cid);
ALTER TABLE place ADD CONSTRAINT fk_place_oid FOREIGN KEY (oid) REFERENCES orders(oid);

set SQL_SAFE_UPDATES = 0;

-- additional constraints for the products table

ALTER TABLE products
ADD CONSTRAINT chk_product_name 
CHECK (name IN ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor'));
ALTER TABLE products
ADD CONSTRAINT chk_product_category 
CHECK (category IN ('Peripheral', 'Networking', 'Computer'));

-- constraints for sell relational table
ALTER TABLE sell
ADD CONSTRAINT chk_sell_price 
CHECK (price BETWEEN 0 AND 100000);
select * from contain;
ALTER TABLE sell
ADD CONSTRAINT chk_quantity_available 
CHECK (quantity_available BETWEEN 0 AND 1000);

-- constraints for the orders table

ALTER TABLE orders
ADD CONSTRAINT chk_shipping_method 
CHECK (shipping_method IN ('UPS', 'FedEx', 'USPS'));
ALTER TABLE orders
ADD CONSTRAINT chk_shipping_cost 
CHECK (shipping_cost BETWEEN 0 AND 500);
ALTER TABLE place
ADD CONSTRAINT chk_valid_order_date
CHECK (order_date <= '2024-10-11'); -- because today is October 11th, 2024

-- converting order_date from a string to a date type
UPDATE place
SET order_date = STR_TO_DATE(order_date, '%m/%d/%Y');

-- QUERIES FOR ASSIGNMENT START HERE

-- query 1: List names and sellers of products that are no longer available (quantity=0)

select p.name as product_name, m.name as seller_name from merchants m
join sell s on s.mid = m.mid   -- join statements to combine necessary tables
join products p on s.pid = p.pid
where quantity_available = 0;  -- this line selects only the products that are not in stock

-- query 2: List names and descriptions of products that are not sold.

select p.name as product_name, p.description as product_description from products p   
left join sell s on p.pid = s.pid    -- to join all matching products to the sell table
where s.pid is null;                 -- this line selects only the products that do not have an associated sell id

-- query 3: How many customers bought SATA drives but not any routers?

SELECT COUNT(distinct c.cid) AS customer_count -- using the distinct function to prevent customers from 
FROM customers c
inner JOIN place pl on c.cid = pl.cid          -- join statements to combine necessary tables
inner JOIN orders o on pl.oid = o.oid
inner JOIN contain ct ON pl.oid = ct.oid
inner JOIN products p ON ct.pid = p.pid
WHERE p.description like '%SATA%'              -- using like to get all descriptions with sata somewhere within
and 
c.cid not in (                                 -- subquery to find out all customers who ordered routers (and not include them)
    SELECT distinct c2.cid
    FROM customers c2
    inner JOIN place pl2 ON c2.cid = pl2.cid
    inner JOIN orders o2 on pl2.oid = o2.oid
    inner JOIN contain ct2 ON pl2.oid = ct2.oid
    inner JOIN products p2 ON ct2.pid = p2.pid
    WHERE p2.name = 'Router'                   -- using = because the name cells contain only one word
);

-- Query 4: HP had 20 % sale on Networking Products

update sell s                                                               -- update function used to alter the sell table
set price = price * 0.8                                                     -- subtract by 20 percent
where s.pid in 
(select p.pid from products p where p.category = 'Networking') and s.mid    -- subquery to find products which satisfy conditions
in (select m.mid from merchants m where m.name = 'HP');

-- Query 5: What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).

select m.name, p.name as product_name, s.price as product_price from merchants m 
join sell s on s.mid = m.mid                                           -- join statements to group necessary data together
join products p on s.pid = p.pid
join contain c on c.pid = p.pid
join orders o on c.oid = o.oid
join place pl on o.oid = pl.oid
join customers cust on pl.cid = cust.cid
where cust.fullname = 'Uriel Whitney' and m.name = 'Acer';             -- where statement to find rows that satisfiy the conditions                     

-- Query 6: List the annual total sales for each company (sort the results along the company and the year attributes).

select m.name as company_name, YEAR(p.order_date) as the_year, SUM(s.price * s.quantity_available) as annual_total_sales from merchants m
join sell s on m.mid = s.mid                -- join statements to link tables
join contain c on s.pid = c.pid
join orders o ON c.oid = o.oid
join place p on o.oid = p.oid
Group by m.name, the_year                     
Order by m.name, the_year;                  -- orders the companies alphabetically and the year from least to greatest

-- Query 7: Which company had the highest annual revenue and in what year?

SELECT company_name, year, MAX(total_sales) AS highest_annual_revenue              -- outer query find the maximum total sales from each company
FROM (
    SELECT m.name AS company_name, YEAR(pl.order_date) AS year, SUM(s.price * s.quantity_available) AS total_sales
    FROM merchants m                                                               -- inner query finds the total sales in each company per year
    JOIN sell s ON m.mid = s.mid                                                   -- join statements to combine tables for necessary information
    JOIN contain ct ON s.pid = ct.pid
    JOIN orders o ON ct.oid = o.oid
    JOIN place pl ON o.oid = pl.oid
    GROUP BY m.name, YEAR(pl.order_date)
) AS annual_sales
GROUP BY company_name, year                                                
ORDER BY highest_annual_revenue desc
limit 1;                                                                           -- this ensures only the company with the highest yearly revenue
																				   -- is displayed    
-- Query 8: on average, what was the cheapest shipping method used ever?

select shipping_method, avg(shipping_cost) as avg_cost from orders   -- calculates the average shipping cost for each shipping method
Group by shipping_method
Order by avg_cost 
limit 1;                                                             -- ensures that only the shipping_method with the least average cost is displayed

-- Query 9: What is the best sold ($) category for each company?

With sales_per_category as (                                 -- this is a subquery for getting the total sales per category
select m.name as company, p.category, sum(s.price * s.quantity_available) as total_sales
from merchants m
join sell s on m.mid = s.mid
join products p on s.pid = p.pid
group by m.name, p.category
),
highest_sales as                                             -- this is a subquery for getting the highest sales per category
(select company, max(total_sales) as max_sales
from sales_per_category 
group by company
)
select cat.company, cat.category, cat.total_sales            -- this final part of the query combines the results calculated above to get highest sold category 
from sales_per_category cat                                  -- per company
join highest_sales hs on cat.company = hs.company            -- join statement to combine necessary results
and cat.total_sales = max_sales;

-- query 10: For each company find out which customers have spent the most and the least amounts.

WITH customer_spent_money AS (
    SELECT m.name AS company_name, c.fullname AS customer_name,          -- first subquery finds the total that customers spent per company
           SUM(s.price * s.quantity_available) AS total_spent
    FROM merchants m
    JOIN sell s ON m.mid = s.mid                                         -- join statements used to combine tables to get necessary information
    JOIN contain ct ON s.pid = ct.pid
    JOIN products p ON s.pid = p.pid
    JOIN orders o ON ct.oid = o.oid
    JOIN place pl ON o.oid = pl.oid
    JOIN customers c ON pl.cid = c.cid
    GROUP BY m.name, c.fullname
)
SELECT csm.company_name, csm.customer_name, csm.total_spent              -- second subquery finds the maximum and minimum money spent
FROM Customer_spent_money csm
JOIN (
    SELECT company_name, 
           MAX(total_spent) AS max_spent, 
           MIN(total_spent) AS min_spent
    FROM customer_spent_money
    GROUP BY company_name
) AS max_min ON csm.company_name = max_min.company_name 
AND (csm.total_spent = max_min.max_spent OR csm.total_spent = max_min.min_spent)
ORDER BY csm.company_name, csm.total_spent DESC;                         -- this ensures that the total spent for each company is grouped by most
																	     -- first, then least second