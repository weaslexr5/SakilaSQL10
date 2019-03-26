-- Create these queries to develop greater fluency in SQL, an important database language.
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
  SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
  FROM actor;
  
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select * from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor 
where last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor
where last_name LIKE '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,  country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `Description` BLOB NULL AFTER `last_update`;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `Description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as actor_count
from actor group by last_name
order by actor_count desc;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
select last_name, count(*) as actor_count2
from actor 
group by last_name
having count(actor_id) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE `sakila`.`actor` SET `first_name` = 'HARPO' WHERE (`actor_id` = '172');

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE `sakila`.`actor` SET `first_name` = 'GROUCHO' WHERE (`actor_id` = '172');

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, staff.address_id, address.address
from address
inner join staff on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.first_name, staff.last_name, sum(payment.amount)
from staff
inner join payment on staff.staff_id = payment.staff_id
where payment_date LIKE "2005-05-%";

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select count(film_actor.actor_id), film.title
from film
inner join film_actor
using (film_id)
group by film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) 
from inventory
where film_id IN
(
select film_id
from film
where title = "Hunchback Impossible"
);

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount)
from customer
inner join payment using (customer_id)
group by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the 
-- letters K and Q whose language is English.
select title 
from film
where title LIKE "K%" or title LIKE "Q%" and title IN
(
select title  
from film
where language_id IN
(
select language_id
from language
where name = "English"
)
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id IN
(
select actor_id
from film_actor
where film_id IN
(
select film_id
from film
where title = "Alone Trip" 
)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select customer.first_name, customer.last_name, customer.email, 
customer.address_id, address.city_id, city.country_id,
country.country_id
from customer
inner join address on customer.address_id = address.address_id
inner join city on city.country_id = country.country_id
where country.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title
from film
where film_id IN
(
select film_id
from film_category
where category_id IN
(
select category_id
from category
where name = "Family"
)
);

-- 7e. Display the most frequently rented movies in descending order.
select title
from film group by title
order by rental_rate desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    store.store_id, SUM(amount) AS revenue
FROM
    store
        INNER JOIN
    staff ON store.store_id = staff.store_id
        INNER JOIN
    payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    store.store_id, city.city, country.country
FROM
    store
        INNER JOIN
    address ON store.address_id = address.address_id
        INNER JOIN
    city ON address.city_id = city.city_id
        INNER JOIN
    country ON city.country_id = country.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
SELECT 
    name, SUM(p.amount) AS gross_revenue
FROM
    category c
        INNER JOIN
    film_category fc ON fc.category_id = c.category_id
        INNER JOIN
    inventory i ON i.film_id = fc.film_id
        INNER JOIN
    rental r ON r.inventory_id = i.inventory_id
        RIGHT JOIN
    payment p ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS top_five_genres;
CREATE VIEW top_five_genres AS

SELECT 
    name, SUM(p.amount) AS gross_revenue
FROM
    category c
        INNER JOIN
    film_category fc ON fc.category_id = c.category_id
        INNER JOIN
    inventory i ON i.film_id = fc.film_id
        INNER JOIN
    rental r ON r.inventory_id = i.inventory_id
        RIGHT JOIN
    payment p ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop view top_five_genres