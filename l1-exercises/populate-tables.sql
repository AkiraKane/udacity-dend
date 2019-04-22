-- Populate, via insert statements, the Fact and Dimension tables

-- dimDate - Date Dimension table
INSERT INTO dimDate (date_key, date, year, quarter, month, day, week, is_weekend)
SELECT DISTINCT(TO_CHAR(payment_date :: DATE, 'yyyyMMDD')::integer) AS date_key,
       date(payment_date)                                           AS date,
       EXTRACT(year FROM payment_date)                              AS year,
       EXTRACT(quarter FROM payment_date)                           AS quarter,
       EXTRACT(month FROM payment_date)                             AS month,
       EXTRACT(day FROM payment_date)                               AS day,
       EXTRACT(week FROM payment_date)                              AS week,
       CASE WHEN EXTRACT(ISODOW FROM payment_date) IN (6, 7) THEN true ELSE false END AS is_weekend
FROM payment;

-- dimCustomer - Customer Dimension table
INSERT INTO dimCustomer (customer_key, customer_id, first_name, last_name, email, address, 
                         address2, district, city, country, postal_code, phone, active, 
                         create_date, start_date, end_date)
SELECT c.customer_id as customer_key,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    a.address2,
    a.district,
    ci.city,
    co.country,
    a.postal_code,
    a.phone,
    c.active,
    c.create_date,
       now()         AS start_date,
       now()         AS end_date
FROM customer c
JOIN address a  ON (c.address_id = a.address_id)
JOIN city ci    ON (a.city_id = ci.city_id)
JOIN country co ON (ci.country_id = co.country_id);

-- dimMovie - Movie Dimension table
INSERT INTO dimMovie (movie_key, film_id, title, description, release_year, language, original_language, rental_duration,
                     length, rating, special_features)
SELECT f.film_id as movie_key,
    f.film_id,
    f.title,
    f.description,
    f.release_year,
    l.name as language,
    orig_lang.name AS original_language,
    f.rental_duration,
    f.length,
    f.rating,
    f.special_features
FROM film f
JOIN language l              ON (f.language_id=l.language_id)
LEFT JOIN language orig_lang ON (f.original_language_id = orig_lang.language_id);

-- dimStore - Store Dimension table
insert into dimStore (store_key, store_id, address, address2, district, city, country, postal_code,
                     manager_first_name, manager_last_name, start_date, end_date)
select s.store_id as store_key,
	s.store_id,
    a.address,
    a.address2,
    a.district,
    ci.city,
    co.country,
    a.postal_code,
    sta.first_name,
    sta.last_name,
    now()         AS start_date,
	now()         AS end_date
from store as s
join address as a on (s.address_id = a.address_id)
join city as ci on (a.city_id = ci.city_id)
JOIN country co ON (ci.country_id = co.country_id)
join staff sta on (s.manager_staff_id = sta.staff_id);


-- factSales - Sales Fact table
insert into factSales (date_key, customer_key, movie_key, store_key, sales_amount)
select to_char(p.payment_date :: DATE, 'yyyyMMDD')::integer as sales_key,
        p.customer_id as customer_key,
        i.film_id as movie_key,
        i.store_id as story_key,
        p.amount as sales_amount
from payment as p
join rental as r on (p.rental_id = r.rental_id)
join inventory as i on (r.inventory_id = i.inventory_id)