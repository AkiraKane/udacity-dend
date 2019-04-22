-- Queries on Pagila data

-- Fact table contains keys to each dimension
SELECT movie_key, date_key, customer_key, sales_amount
FROM factSales 
limit 5;

-- Can query for information about which movie rentals were rented each month, in each city, and the sum of the movie rental (for the month and city combo)

-- Query using the Star Schema tables:
SELECT dimMovie.title, dimDate.month, dimCustomer.city, sum(sales_amount) as revenue
FROM factSales 
JOIN dimMovie    on (dimMovie.movie_key      = factSales.movie_key)
JOIN dimDate     on (dimDate.date_key         = factSales.date_key)
JOIN dimCustomer on (dimCustomer.customer_key = factSales.customer_key)
group by (dimMovie.title, dimDate.month, dimCustomer.city)
order by dimMovie.title, dimDate.month, dimCustomer.city, revenue desc;

-- Query using the 3NF tables ('source' tables)
SELECT f.title, EXTRACT(month FROM p.payment_date) as month, ci.city, sum(p.amount) as revenue
FROM payment p
JOIN rental r    ON ( p.rental_id = r.rental_id )
JOIN inventory i ON ( r.inventory_id = i.inventory_id )
JOIN film f ON ( i.film_id = f.film_id)
JOIN customer c  ON ( p.customer_id = c.customer_id )
JOIN address a ON ( c.address_id = a.address_id )
JOIN city ci ON ( a.city_id = ci.city_id )
group by (f.title, month, ci.city)
order by f.title, month, ci.city, revenue desc;

-- Slicing and Dicing data

-- Simple cube:
-- Write a query that calculates the revenue (sales_amount) by day, rating, and city.
-- Sort by revenue in descending order and limit to the first 20 rows.
select d.day,
	m.rating,
    c.city,
    sum(f.sales_amount) as revenue
from factSales as f
join dimDate as d on (f.date_key = d.date_key)
join dimMovie as m on (f.movie_key = m.movie_key)
join dimCustomer as c on (f.customer_key = c.customer_key)
group by (day, rating, city)
order by revenue desc
limit 20;

-- Slicing the simple cube:
-- 'Fix' the rating dimension to a single value, 'PG-13'
select d.day,
	m.rating,
    c.city,
    sum(f.sales_amount) as revenue
from factSales as f
join dimDate as d on (f.date_key = d.date_key)
join dimMovie as m on (f.movie_key = m.movie_key)
join dimCustomer as c on (f.customer_key = c.customer_key)
where m.rating = 'PG-13'
group by (day, rating, city)
order by revenue desc
limit 20;

-- Dicing the simple cube:
-- Create a subcube of the initial cube that:
-- (1) has ratings of PG or PG-13
-- (2) in Bellevue or Lancaster
-- (3) day is either 1, 15 or 30
select d.day,
	m.rating,
    c.city,
    sum(f.sales_amount) as revenue
from factSales as f
join dimDate as d on (f.date_key = d.date_key)
join dimMovie as m on (f.movie_key = m.movie_key)
join dimCustomer as c on (f.customer_key = c.customer_key)
where m.rating in ('PG', 'PG-13')
	and c.city in ('Bellevue', 'Lancaster')
    and d.day in ('1', '15', '30')
group by (day, rating, city)
order by revenue desc
limit 20;

-- Roll-up the cube from city -> country level
select d.day,
	m.rating,
    c.country,
    sum(f.sales_amount) as revenue
from factSales as f
join dimDate as d on (f.date_key = d.date_key)
join dimMovie as m on (f.movie_key = m.movie_key)
join dimCustomer as c on (f.customer_key = c.customer_key)
group by (day, rating, country)
order by revenue desc
limit 20;

-- Drill-down the cube from country -> district
select d.day,
	m.rating,
    c.district,
    sum(f.sales_amount) as revenue
from factSales as f
join dimDate as d on (f.date_key = d.date_key)
join dimMovie as m on (f.movie_key = m.movie_key)
join dimCustomer as c on (f.customer_key = c.customer_key)
group by (day, rating, district)
order by revenue desc
limit 20;

-- Creating Grouping Sets

-- Total revenue
select sum(sales_amount) as revenue
from factSales;

-- Revenue by Country
select country, sum(sales_amount) as revenue
from factSales
join dimStore on (factSales.store_key = dimStore.store_key)
group by dimStore.country;

-- Revenue by Month
select month, sum(sales_amount) as revenue
from factSales
join dimDate on (factSales.date_key = dimDate.date_key)
group by month
order by month;

-- Revenue by Month and Country
select month, country, sum(sales_amount) as revenue
from factSales
join dimDate on (factSales.date_key = dimDate.date_key)
join dimStore on (factSales.store_key = dimStore.store_key)
group by month, country
order by month, country;

-- Use 'Grouping Sets' function to calculate total revenue given the various groupings performed above
-- Grouping Sets will compute the following within the same query:
-- (1) revenue by country
-- (2) revenue by month
-- (3) revenue by month and country
-- (4) total revenue
select month, country, sum(sales_amount) as revenue
from factSales
join dimDate on (factSales.date_key = dimDate.date_key)
join dimStore on (factSales.store_key = dimStore.store_key)
group by grouping sets (
	(), -- total revenue
	month, -- revenue by month
	country, -- revenue by country
	(month, country) -- revenue by month and country
);

-- Can also 'materialize' the data, and create a table with the grouped data
create table month_country_revenue as (
    select month, country, sum(sales_amount) as revenue
    from factSales
    join dimDate on (factSales.date_key = dimDate.date_key)
    join dimStore on (factSales.store_key = dimStore.store_key)
    group by grouping sets (
        (), -- total revenue
        month, -- revenue by month
        country, -- revenue by country
        (month, country) -- revenue by month and country
    )
);

-- And then can query the (1) total revenue
select revenue
from month_country_revenue
where month is null
	and country is null
    
-- Or (2) revenue by month
select month, revenue
from month_country_revenue
where month is not null
	and country is null

-- Or (3) revenue by country
select country, revenue
from month_country_revenue
where month is null
	and country is not null

-- Or (4) revenue by month and country
select month, country, revenue
from month_country_revenue
where month is not null
	and country is not null
    
-- Instead of using the 'grouping set' function, can also use the 'cube' function
select month, country, sum(sales_amount) as revenue
from factSales
join dimDate on (factSales.date_key = dimDate.date_key)
join dimStore on (factSales.store_key = dimStore.store_key)
group by cube (month, country);