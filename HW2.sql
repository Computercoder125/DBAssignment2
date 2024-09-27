
-- query 1: finds average food price at each restaurant
SELECT r.name AS restaurant_name, avg(price) AS avg_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID -- links the serves table
JOIN foods f ON s.foodID = f.foodID  -- links the foods table
GROUP BY r.name;

-- query 2: finds maximum price of foods at each restaurant
SELECT r.name AS restaurant_name, MAX(price) AS max_food_price -- using aggregate function MAX
FROM restaurants r
JOIN serves s ON r.restID = s.restID -- linking serves table
JOIN foods f ON s.foodID = f.foodID  -- linking foods table
GROUP BY r.name; 

-- query 3: finds the count of each food type at each restaurant.
SELECT r.name as restaurant_name, count(distinct f.type) as num_of_food_types
from restaurants r
join serves s ON r.restID = s.restID -- linking the serves table
join foods f ON s.foodID = f.foodID -- linking the food table
GROUP BY r.name;  -- organizing data by the restaurant's name

-- query 4: finds average food price for each chef
SELECT c.name AS chef_name, avg(price) AS avg_food_price
FROM chefs c
JOIN works w ON c.chefID = w.chefID -- linking the works table to get chef ID
JOIN serves s ON w.restID = s.restID -- linking the serves table to get restaurant ID
JOIN foods f ON s.foodID = f.foodID -- linking the food table
GROUP BY c.name;

-- query 5: finds restaurants with highest average food price
SELECT r.name AS restaurant_name, avg(f.price) AS avg_price -- aggregate function max being used
FROM restaurants r
JOIN serves s ON r.restID = s.restID                        -- serves table is linked
JOIN foods f ON s.foodID = f.foodID                         -- foods table is linked
GROUP BY r.name
Having AVG(f.price) = (                                     -- Using having statement to include only restaurants with the highest price
    SELECT MAX(sub.avg_price)                               -- subquery to find the maximum average price
    FROM (
        SELECT r.restID, AVG(f.price) AS avg_price
        FROM restaurants r
        JOIN serves s ON r.restID = s.restID
        JOIN foods f ON s.foodID = f.foodID
        GROUP BY r.restID
    ) AS sub
    );

-- Extra Credit: Determine which chef has the highest average price of the foods served at the restaurants where they work. Include the chef’s name, 
-- the average food price, and the names of the restaurants where the chef works. 
-- Sort the results by the average food price in descending order.
SELECT 
    c.name AS chef_name, 
    GROUP_CONCAT(DISTINCT r.name) AS rest_name,  -- grouping all restaurant names associated with the chef in one cell
    AVG(price) AS avg_food_price
FROM 
    chefs c
JOIN 
    works w ON c.chefID = w.chefID               -- linking works table
JOIN 
    restaurants r ON w.restID = r.restID         -- linking restaurants table
JOIN 
    serves s ON r.restID = s.restID              -- linking serves table
JOIN 
    foods f ON s.foodID = f.foodID               -- linking foods table
GROUP BY 
    c.name                     
Order by avg_food_price desc;