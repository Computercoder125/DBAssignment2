create database assignment3;

select * from merchants;

select * from products;

select * from customers;

select * from sell;

select * from contain;

select * from orders;


select * from place;
-- query 1: List names and sellers of products that are no longer available (quantity=0)

select p.name, m.name from merchants m
join sell s on s.mid = m.mid
join products p on s.pid = p.pid
where quantity_available = 0;
-- group by m.name

-- query 2: List names and descriptions of products that are not sold.

select p.name, p.description from products p
left join sell s on s.pid = p.pid
where quantity_available = 0;

-- query 3: How many customers bought SATA drives but not any routers?

SELECT COUNT(DISTINCT c.cid) AS customer_count
FROM customers c
JOIN place pl ON c.cid = pl.cid
JOIN contain ct ON pl.oid = ct.oid
JOIN products p ON ct.pid = p.pid
WHERE p.name LIKE '%Super Drive%'
AND c.cid NOT IN (
    SELECT DISTINCT c2.cid
    FROM customers c2
    JOIN place pl2 ON c2.cid = pl2.cid
    JOIN contain ct2 ON pl2.oid = ct2.oid
    JOIN products p2 ON ct2.pid = p2.pid
    WHERE p2.name LIKE '%router%'
);
SELECT COUNT(DISTINCT c.cid) AS customer_count
FROM customers c
join place p on p.cid = c.cid
join orders o on p.oid = o.oid
join contain c on c.oid = o.oid
join products p on c.pid = p.pid
where p.name = 'Super Drive'
AND c.cid NOT IN (
    SELECT DISTINCT c.cid
    FROM customers c
    JOIN place p ON c.cid = p.cid
    JOIN contain c ON p.oid = c.oid
    JOIN products p ON c.pid = p.pid
    WHERE p2.name Like '%router%'
);

-- Query 4: HP had 20 % sale on Networking Products

update sell s
set price = price * 0.8
where s.pid in 
(select p.pid from products p where p.category = 'Networking') and s.mid in (select m.mid from merchants m where m.name = 'HP');


-- Query 5: What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).

select m.name, p.name as product_name, s.price as product_price from merchants m
join sell s on s.mid = m.mid
join products p on s.pid = p.pid
join contain c on c.pid = p.pid
join orders o on c.oid = o.oid
join place pl on o.oid = pl.oid
join customers cust on pl.cid = cust.cid
where cust.fullname = 'Uriel Whitney' and m.name = 'Acer'
Group by m.name, product_name, product_price;
-- Query 6 List the annual total sales for each company (sort the results along the company and the year attributes).

select m.name as company_name, YEAR(p.order_date) as the_year, SUM(s.price) as annual_total_sales from merchants m
join sell s on m.mid = s.mid
join contain c on s.pid = c.pid
join place p on c.oid = p.oid
Group by m.name, the_year
Order by m.name, the_year;

SELECT m.name AS company, YEAR(pl.order_date) AS year, SUM(s.price * ct.quantity) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain ct ON s.pid = ct.pid
JOIN place pl ON ct.oid = pl.oid
GROUP BY m.name, YEAR(pl.order_date)
ORDER BY m.name, year;

-- Query 8: on average, what was the cheapest shipping method used ever?

select shipping_method, sum(shipping_cost) as total_cost from orders
Group by shipping_method
Order by total_cost
limit 1;

-- Query 9: What is the best sold ($) category for each company?

select m.name, p.category as category, sum(s.price) as sum_price from merchants m
join sell s on m.mid = s.mid
join contain ct ON s.pid = ct.pid
join products p on s.pid = p.pid
group by m.name, category
Order by m.name, sum_price desc;

SELECT m.name AS company_name, p.category, SUM(s.price) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain ct ON s.pid = ct.pid
JOIN products p ON s.pid = p.pid
GROUP BY m.name, p.category
ORDER BY company_name, total_sales DESC;
-- limit 1;
select YEAR() as year from place;
