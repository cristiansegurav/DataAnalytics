/* Query to solve question 1 */

SELECT film_cat.film_title as film_title, film_cat.category_name as category_name, rental_inventory.rental_count as rental_count
FROM (WITH film_title_cat_id as (SELECT film.film_id as film_id, film.title as film_title, film_category.category_id as category_id 
  FROM film
  JOIN film_category
    ON film_category.film_id = film.film_id)
SELECT film_title_cat_id.film_id as film_id, film_title_cat_id.film_title as film_title, category.name as category_name
   FROM film_title_cat_id
   JOIN category
     ON film_title_cat_id.category_id = category.category_id) film_cat
JOIN
(
  SELECT inventory.film_id as film_id, COUNT(rental.rental_id) as rental_count
    FROM rental
    JOIN inventory 
      ON inventory.inventory_id = rental.inventory_id
  GROUP BY film_id
) rental_inventory
ON film_cat.film_id = rental_inventory.film_id
WHERE film_cat.category_name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 2, 1;


/*film_cat example

film_id	film_title		category_name
133		Chamber Italian		Music
384		Grosse Wonderful	Music
8		Airport Pollock		Horror
*/

/*rental_inventory example
  
film_id	rental_count
251	    18
106	    7
681	    21
285	    30
120	    9
*/

/* Query to solve question 2 */

SELECT film.title, 
       film.film_id, 
       film_category.category_id,
       film.rental_duration, 
       NTILE(4) OVER (ORDER BY film.rental_duration) as standard_quartile
FROM film
JOIN film_category
  ON film_category.film_id = film.film_id
ORDER BY standard_quartile ASC

/* result sample
title			film_id	category_id	rental_duration	standard_quartile
Zorro Ark		1000		5				3				1
Ace Goldfinger	2			11				3				1
*/

WITH film_std_qtl as (SELECT film.title, 
       film.film_id, 
       film_category.category_id,
       film.rental_duration, 
       NTILE(4) OVER (ORDER BY film.rental_duration) as standard_quartile
FROM film
JOIN film_category
  ON film_category.film_id = film.film_id
ORDER BY standard_quartile ASC)

SELECT film_std_qtl.title,
       category.name,
       film_std_qtl.rental_duration,
       film_std_qtl.standard_quartile
  FROM film_std_qtl
  JOIN category
    ON film_std_qtl.category_id = category.category_id
 WHERE category.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');
/* Result sample 
 title					  name	         rental_duration	standard_quartile
Zorro Ark				 Comedy					3					1
Alone Trip				  Music					3					1
Anaconda Confessions	Animation				3					1
Arizona Bang			Classics				3					1
*/


/* Query to solve question 3 */

WITH film_cat as 
( WITH film_std_qtl as (SELECT film.title, 
       film.film_id, 
       film_category.category_id,
       film.rental_duration, 
       NTILE(4) OVER (ORDER BY film.rental_duration) as standard_quartile
FROM film
JOIN film_category
  ON film_category.film_id = film.film_id
ORDER BY standard_quartile ASC)

SELECT film_std_qtl.title,
       category.name,
       film_std_qtl.rental_duration,
       film_std_qtl.standard_quartile
  FROM film_std_qtl
  JOIN category
    ON film_std_qtl.category_id = category.category_id
 WHERE category.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))
SELECT film_cat.name,
       film_cat.standard_quartile,
       COUNT(*)
FROM film_cat
GROUP BY 1,2
ORDER BY 1,2;

/* preview 

name		standard_quartile	count
Animation		1				20
Animation		2				14
Animation		3				14
Animation		4				18
Children		1				15
Children		2				16
Children		3				15

*/

/* Query to solve question 4 */

SELECT DATE_PART('month', r.rental_date) Rental_month,
	   DATE_PART('year', r.rental_date) Rental_year,
       i.store_id AS Store_ID,
       COUNT(*) AS Count_rentals
  FROM inventory AS i
  JOIN rental AS r
    ON i.inventory_id = r.inventory_id
    GROUP BY Rental_month, Rental_year, i.store_id
    ORDER BY Count_rentals DESC;
	
/* preview
rental_month	rental_year	store_id	count_rentals
7	2005	2	3375
7	2005	1	3334
8	2005	2	2885
*/
