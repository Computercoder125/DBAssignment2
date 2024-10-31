create database assignment4;

-- adding primary key constraints
select * from address;
ALTER TABLE address ADD CONSTRAINT pk_address PRIMARY KEY (address_id);
ALTER TABLE actor ADD CONSTRAINT pk_actor PRIMARY KEY (actor_id);
ALTER TABLE category ADD CONSTRAINT pk_category PRIMARY KEY (category_id);
ALTER TABLE city ADD CONSTRAINT pk_city PRIMARY KEY (city_id);
ALTER TABLE country ADD CONSTRAINT pk_country PRIMARY KEY (country_id);
ALTER TABLE customer ADD CONSTRAINT pk_customer PRIMARY KEY (customer_id);
ALTER TABLE film ADD CONSTRAINT pk_film PRIMARY KEY (film_id);
ALTER TABLE inventory ADD CONSTRAINT pk_inventory Primary Key (inventory_id);
ALTER TABLE language add constraint pk_language_id Primary Key (language_id);
ALTER TABLE payment ADD CONSTRAINT pk_payment PRIMARY KEY (payment_id);
ALTER TABLE rental ADD CONSTRAINT pk_rental PRIMARY KEY (rental_id);
ALTER TABLE staff ADD CONSTRAINT pk_staff PRIMARY KEY (staff_id);
ALTER TABLE store ADD CONSTRAINT pk_store PRIMARY KEY (store_id); 
ALTER TABLE film_actor ADD CONSTRAINT fk_actor PRIMARY KEY (actor_id, film_id);
ALTER TABLE film_category ADD CONSTRAINT fk_film_category Primary Key (category_id, film_id);

-- adding foreign key constraints

ALTER TABLE address ADD CONSTRAINT fk_address_city_id FOREIGN KEY (city_id) REFERENCES city(city_id);
ALTER TABLE city ADD CONSTRAINT fk_city_country_id FOREIGN KEY (country_id) REFERENCES country(country_id);
ALTER TABLE customer ADD CONSTRAINT fk_customer_address_id FOREIGN KEY (address_id) REFERENCES address(address_id);
ALTER TABLE film ADD CONSTRAINT fk_film_language_id FOREIGN KEY (language_id) REFERENCES language(language_id);
ALTER TABLE film_actor ADD CONSTRAINT fk_film_actor_actor_id FOREIGN KEY (actor_id) REFERENCES actor(actor_id);
ALTER TABLE film_actor ADD CONSTRAINT fk_film_actor_film_id FOREIGN KEY (film_id) REFERENCES film(film_id);
ALTER TABLE film_category ADD CONSTRAINT fk_film_category_category_id FOREIGN KEY (category_id) REFERENCES category(category_id);
ALTER TABLE film_category ADD CONSTRAINT fk_film_category_film_id FOREIGN KEY (film_id) REFERENCES film(film_id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_film_id FOREIGN KEY (film_id) REFERENCES film(film_id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_store_id FOREIGN KEY (store_id) REFERENCES store(store_id);
ALTER TABLE payment ADD CONSTRAINT fk_payment_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE payment ADD CONSTRAINT fk_payment_staff_id FOREIGN KEY (staff_id) REFERENCES staff(staff_id);
ALTER TABLE payment ADD CONSTRAINT fk_payment_rental_id FOREIGN KEY (rental_id) REFERENCES rental(rental_id);
ALTER TABLE rental ADD CONSTRAINT fk_rental_inventory_id FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id);
ALTER TABLE rental ADD CONSTRAINT fk_rental_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE staff ADD CONSTRAINT fk_staff_address_id FOREIGN KEY (address_id) REFERENCES address(address_id);
ALTER TABLE store ADD CONSTRAINT fk_store_address_id FOREIGN KEY (address_id) REFERENCES address(address_id);

-- additional constraints based on the assignment criteria

ALTER TABLE category
ADD CONSTRAINT chk_category_name
CHECK (name IN ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'));

ALTER TABLE film
ADD CONSTRAINT chk_special_features
CHECK(special_features IN('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers'));

ALTER TABLE film
ADD CONSTRAINT chk_duration
CHECK(2 < rental_duration < 8);

ALTER TABLE film
ADD CONSTRAINT chk_rate
CHECK(0.99 <= rental_rate <= 6.99);

ALTER TABLE film
ADD CONSTRAINT chk_length
CHECK(30 < length < 200);

ALTER TABLE film
ADD CONSTRAINT chk_ratings
CHECK(rating in ('PG', 'G', 'NC-17', 'PG-13', 'R'));

ALTER TABLE film
ADD CONSTRAINT chk_repl_cost
CHECK(5.00 <= replacement_cost <= 100.00);

ALTER TABLE payment
ADD CONSTRAINT chk_amount
CHECK(amount >= 0);

-- checking for valid rental dates 
ALTER TABLE rental
ADD CONSTRAINT chk_rent_date
CHECK(rental_date <= '2024-10-26');

ALTER TABLE rental 
ADD CONSTRAINT chk_ret_date
CHECK(return_date <= '2024-10-26');

ALTER TABLE rental
ADD CONSTRAINT chk_both_dates
CHECK(return_date > rental_date);

-- checking if active has a binary value
ALTER TABLE customer
ADD CONSTRAINT chk_active
CHECK(active IN(0, 1));

-- Query 1: What is the average length of films in each category? List the results in alphabetic order of categories.
													--
select c.name as cat_name, avg(f.length) as average_length from category c  -- creating category name and average length columns
inner join film_category fc on c.category_id = fc.category_id               -- join statements to connect tables
inner join film f on fc.film_id = f.film_id
group by cat_name
order by cat_name;                                                          -- orders by category name from A to Z

-- Query 2: Which categories have the longest and shortest average film lengths?

select c.name as cat_name, avg(f.length) as avg_length from category c      
inner join film_category fc on c.category_id = fc.category_id
inner join film f on fc.film_id = f.film_id
group by cat_name
having avg_length >= (                                                      -- having clause limits displayed categories to only desired ones
select avg(f.length) from category c
inner join film_category fc on c.category_id = fc.category_id
inner join film f on fc.film_id = f.film_id
group by c.name
order by avg(f.length) desc
limit 1)
or avg_length <=                                                            -- second part of having clause finds out if category's average
(select avg(f.length) from category c                                       -- length is less than or equal to ALL average lengths
inner join film_category fc on c.category_id = fc.category_id
inner join film f on fc.film_id = f.film_id
group by c.name
order by avg(f.length)
limit 1);

-- Query 3: Which customers have rented action but not comedy or classic movies?

select distinct c.first_name as cust_first_name, c.last_name as cust_last_name from customer c    
inner join rental on c.customer_id = rental.customer_id                            -- join statements to get necessary data 
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film_category on inventory.film_id = film_category.film_id
inner join category cat on film_category.category_id = cat.category_id
where cat.name = 'Action'                                                          -- where clause filters customers' names only if
and c.customer_id not in (														   -- they rented movies 
select c2.customer_id from customer c2
inner join rental on c2.customer_id = rental.customer_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film_category on inventory.film_id = film_category.film_id
inner join category cat2 on film_category.category_id = cat2.category_id
where cat2.name = 'Comedy' or cat2.name = 'Classic'                                -- other where clause limits customers names to 
);                                                                                 -- those who did not rent comedy or classic movies

-- Query 4: Which actor has appeared in the most English-language movies?

select first_name, last_name from actor   
inner join film_actor fa on actor.actor_id = fa.actor_id
inner join film f on fa.film_id = f.film_id
inner join language l on f.language_id = l.language_id
where l.name = 'English'                                                           -- filters movies that are in english language only
group by first_name, last_name													   -- (this is denoted by the name in the language table being
order by count(f.title) desc                                                       -- english)
limit 1;                                                                           -- limit 1 displays only the maximum result

-- Query 5: How many distinct movies were rented for exactly 10 days from the store where Mike works?

select count(distinct f.title) as movie_count from film f                          
inner join inventory i on i.film_id = f.film_id   
inner join store st on i.store_id = st.store_id
inner join staff s on st.store_id = s.store_id
inner join rental r on i.inventory_id = r.inventory_id
where DATEDIFF(r.return_date, r.rental_date) = 10 and s.first_name = 'Mike';
-- datediff function is used to calculate the difference between the return and rental dates (ie. length of a rental), 
-- where clause limits results to only include stores with first name 'Mike' and the difference 10

-- Query 6: Alphabetically list actors who appeared in the movie with the largest cast of actors.

select a.first_name as first_name, a.last_name as last_name from actor a        
inner join film_actor fa on a.actor_id = fa.actor_id                             -- join statements in order to access the film titles
inner join film f on fa.film_id = f.film_id
where f.title = 
(select f.title as film_title from film f                                        -- subquery to limit actor's names to only those
inner join film_actor fa on f.film_id = fa.film_id                               -- who are in the film with 
group by f.title
order by count(distinct fa.actor_id) desc
limit 1)
order by last_name;                                                             -- this orders the actors' last names alphabetically