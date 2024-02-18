-- 1)Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2)Which countries have the most invoices?
SELECT billing_country, count(invoice_id) AS "NO. OF INVOICES" FROM invoice
GROUP BY billing_country
ORDER BY "NO.OF INVOICES" DESC
LIMIT 1;

-- 3)WHAT ARE TOP 3 VALUES OF TOTAL INVOICE?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4)WHICH HAS THE BEST CUSTOMERS?
SELECT billing_city, sum(total) AS IT
FROM invoice
GROUP BY billing_city
ORDER BY IT DESC
LIMIT 1;

-- 5)THE PERSON WHO HAVE SPENT THE MOST MONEY WILL BE DECLARED THE BEST CUSTOMER.

SELECT I.customer_id, concat(C.first_name, " ", C.last_name) AS FULL_NAME, 
sum(I.total) AS TOTAL_SPENT
FROM invoice AS I
INNER JOIN customer AS C
ON I.customer_id = C.customer_id
GROUP BY I.customer_id, FULL_NAME
ORDER BY TOTAL_SPENT DESC
LIMIT 1;

-- 1) WRITE QUERY TO RETURN EMAIL,FIRST NAME, LAST NAME & GENRE OF ALL ROCK MUSIC LISTENER.
-- RETURN YOUR LIST ORDERED ALPHAETICALLY BY EMAIL STARTING WITH A.

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.invoice_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
				    SELECT track_id FROM track
                    JOIN genre ON track.genre_id = genre.genre_id
                    WHERE genre.name LIKE "ROCK"
                    )
ORDER BY email;


SELECT DISTINCT email, first_name, last_name, genre.name
FROM customer
JOIN invoice ON customer.customer_id = invoice.invoice_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = "Rock"
ORDER BY email;

-- 2)LETS INVITE THE ARTIST WHO HAVE WRITTEN MOST ROCK MUSIC IN OUR DATASET.
-- WRITE A QUERY TO RETURN ARTIST NAME AND TOTAL TRACK COUNT OF THE TOP 10 ROCK BANDS.

SELECT name, count(name) AS TRACK_COUNT FROM artist
JOIN album ON artist.artist_id = album.artist_id
WHERE album_id IN (
					SELECT album_id FROM track
                    JOIN genre ON track.genre_id = genre.genre_id
                    WHERE genre.name LIKE "rock")
GROUP BY name
ORDER BY TRACK_COUNT DESC
LIMIT 10;

-- 3) RETURN ALL THE TRACK NAME THAT HAVE SONG LENGTH LONGER THAN THE AVERAGE SONG LENGTH.
-- RETURN THE NAME AND MILISECONDS OF EACH TRACK. ORDER BY THE SONG LENGTH LONGER SONG LISTED FIRST.

SELECT NAME, miliseconds AS SONG_LENGTH FROM track
WHERE miliseconds > (SELECT avg(miliseconds) FROM track)
ORDER BY SONG_LENGTH DESC;


-- 1) FIND HOW MUCH AMOUNT SEPNT BY EACH CUSTOMER ON ARTIST?
-- WRITE A QUERY TO RETURN CUSTOMER NAME, ARTIST NAME AND TOTAL SPENT.

SELECT CONCAT(customer.first_name, " ", customer.last_name) AS CUSTOMER_NAME, 
sum(invoice_line.unit_price*invoice_line.quantity) AS TOTAL_SPENT, artist.name AS ARTIST_NAME
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
GROUP BY CUSTOMER_NAME, ARTIST_NAME
ORDER BY TOTAL_SPENT DESC;

-- 2) WE WANT TO FIND OUT THE MOST FAMOUS MUSIC GENRE FOR EACH COUNTRY. WE DETERMINE THE MOST FAMOUS GENRE AS THE GENRE WITH THE HIGHEST AMOUNT OF PURCHASES.
-- WRITE A QUERY TO RETURN THE EACH COUNTRY ALONG WITH THIER TOP GENRE,FOR COUNTRIES WHERE MAX NUMBER OF PURCHASES IS SHARED RETURN THE ALL GENRES.

WITH POPULAR_GENRE AS (
						SELECT count(invoice_line.quantity) AS PURCHASE, customer.country, genre.name,
                        ROW_NUMBER() OVER(partition by customer.country  ORDER BY count(invoice_line.quantity) DESC  ) AS ROWNO
                        FROM invoice_line
                        JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
                        JOIN customer ON invoice.customer_id = customer.customer_id
                        JOIN track ON invoice_line.track_id = track.track_id
                        JOIN genre ON track.genre_id = genre.genre_id
                        GROUP BY 2,3
                        ORDER BY 2)
SELECT * FROM POPULAR_GENRE
WHERE ROWNO <= 1;


-- 3)write a query to determine the customer who spent most on music for each country.
-- write a qurey that returns the country along with thier top customers and how much they spent?
-- for the country where the top amount spent is shared, provide all customer who spent this amount.

WITH customer_country AS(
							SELECT I.customer_id, C.first_name, C.last_name, I.billing_country, sum(I.total) AS TOTAL_SPENT,
                            ROW_NUMBER() OVER(PARTITION BY I.billing_country ORDER BY sum(I.total) DESC) AS ROWNO
                            FROM invoice AS I
                            JOIN customer AS C ON I.customer_id = C.customer_id
                            GROUP BY 1,2,3,4
                            ORDER BY 4, 5 DESC)
SELECT * FROM customer_country
WHERE ROWNO <= 1;
 
                            




