-- easy question set 1 easy level 
-- q1 who is the senior most employee based on job title
select * from employee order by levels desc limit 1;


-- q2 which countries have most invoices
select count(*) as c
,billing_country from invoice group by billing_country
order by c desc limit 1;

-- q3 what are top 3 values of total invoices
select total from invoice order by total desc limit 3;

-- q4 which city has best customers we would like to throw promotional music festival in the city we made the most money .
-- write a query that returns one city that has highest sum of invoices totals. return both the city name &sum of all invoice totals.
select billing_city,sum(total) as total from invoice group by billing_city order by total desc limit 1;

-- -- q5 who is the best customer? customer that has spent the most money will be declared as best customer.
-- write a query that returns the customer that has spent the most money.

select * from customer;
select * from invoice;

select c.customer_id,c.first_name,c.last_name ,
sum(i.total) as spent_money
from customer c
join invoice i on c.customer_id=i.customer_id
group by c.customer_id
order by spent_money desc
limit 1;

-- question set 2 moderate level

-- q1 write query to return email,fist_name,last_name and genre of all rock music listners .
-- return your list ordered alphabetically by email starting with A
select * from genre;
select * from customer;
select * from album;

select distinct c.first_name,c.last_name,c.email
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.genre_id='1'
order by c.email;

-- Q2 LETS INVITE ARTIST WHO HAVE WRITTEN THE MOST ROCK MUSIC IN OUR DATASET .
-- WRITE A QUERY THAT RETURNS A ARTIST NAME AND TOTAL TRACK COUNT OF TOP 1-0 ROCK BANDS

SELECT A.ARTIST_ID,
A.NAME,
COUNT(A.ARTIST_ID)AS TOTAL_TRACK_COUNT
FROM TRACK T
JOIN ALBUM AB ON AB.ALBUM_ID=T.ALBUM_ID
JOIN ARTIST A ON A.ARTIST_ID=AB.ARTIST_ID
JOIN GENRE G ON G.GENRE_ID=T.GENRE_ID
WHERE G.NAME LIKE 'Rock'
GROUP BY A.ARTIST_ID
ORDER BY TOTAL_TRACK_COUNT DESC
LIMIT 10;

-- q3 return all track names that have song length longer than average song length . return the name and milisecond for each track . 
-- order by the song length with the longest song listed first.

select * from track;

SELECT NAME,MILLISECONDS
FROM TRACK
WHERE MILLISECONDS>(SELECT AVG(MILLISECONDS) AS AVG_MILLISECONDS
FROM TRACK ) ORDER BY MILLISECONDS DESC; 

-- QUESTION SET 3-ADVANCE LEVEL 
-- FIND HOW MUCH AMOUNT SPENT BY EACH CUSTOMER ON ARTISTS? WRITE A QUERY TO RETURN CUSTOMER NAME , ARTIST NAME AND TOTAL SPENT.


WITH BEST_SELLING_ARTIST AS
(SELECT A.ARTIST_ID AS ARTIST_ID,
A.NAME AS ARTIST_NAME,
SUM(IL.UNIT_PRICE*IL.QUANTITY) AS TOTAL_SPENT
FROM INVOICE_LINE IL
JOIN TRACK T ON IL.TRACK_ID=T.TRACK_ID
JOIN ALBUM AB ON T.ALBUM_ID=AB.ALBUM_ID
JOIN ARTIST A ON AB.ARTIST_ID =A.ARTIST_ID
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)
SELECT 
CONCAT(C.FIRST_NAME,C.LAST_NAME) AS CUSTOMER_NAME,
BSA.ARTIST_NAME AS ARTIST_NAME,
SUM(IL.UNIT_PRICE*IL.QUANTITY) AS TOTAL_SPENT
FROM CUSTOMER C
JOIN INVOICE I ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON I.INVOICE_ID=IL.INVOICE_ID
JOIN TRACK T ON IL.TRACK_ID=T.TRACK_ID
JOIN ALBUM AB ON T.ALBUM_ID=AB.ALBUM_ID
JOIN ARTIST A ON AB.ARTIST_ID =A.ARTIST_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID=A.ARTIST_ID
GROUP BY 1,2
ORDER BY 3 DESC;

-- Q2 WE WANT TO FIND OUT THE  MOST POPULAR MUSIC GENRE FOR EACH COUNTRY .WE DETERMINE THE MOST POPULAR GENRE AS GENRE WITH HIGHEST AMOUNT OF PURCHASES.
-- WRITE A QUERY THAT RETURNS EACH COUNTRY ALONG WITH TOP GENRE . FOR COUNTRIES WHERE MAXIMUM NUMBER OF PURCHASES IS SHARED RETURN ALL GENRES
WITH TOP_GENRE AS
(
SELECT C.COUNTRY AS COUNTRY,
COUNT(IL.QUANTITY)AS GENRE_PURCHASE,
G.NAME,
G.GENRE_ID,
ROW_NUMBER() OVER(PARTITION BY C.COUNTRY ORDER BY COUNT(IL.QUANTITY) DESC) AS ROW_NUMBER
FROM CUSTOMER C
JOIN INVOICE I ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON I.INVOICE_ID=IL.INVOICE_ID
JOIN TRACK T ON IL.TRACK_ID=T.TRACK_ID
JOIN GENRE G ON T.GENRE_ID=G.GENRE_ID
GROUP BY 1,3,4
ORDER BY 1 ASC ,2 DESC 
)
SELECT * FROM TOP_GENRE WHERE ROW_NUMBER<=1

-- Q3 WRITE A QUERY THAT DETERMINES THE CUSTOMER THAT HAS SPENT THE MOST ON MUSIC FOR EACH COUNTRY.
-- WRITE A QUERY THAT RETURNS THE COUNTRY ALONG WITH TOP CUSTOMER AND HOW MUCH THEY SPENT.FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED ,
-- PROVIDE ALL CUSTOMERS WHO SPENT THOIS AMOUNT
WITH CUSTOMER_COUNTRY AS (
    SELECT 
        CUSTOMER.CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        BILLING_COUNTRY,
        SUM(TOTAL) AS TOTAL_SPENDING,
        ROW_NUMBER() OVER (PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL) DESC) AS ROWNUM
    FROM INVOICE I 
    JOIN CUSTOMER ON I.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
    GROUP BY CUSTOMER.CUSTOMER_ID, FIRST_NAME, LAST_NAME, BILLING_COUNTRY
)
SELECT * 
FROM CUSTOMER_COUNTRY 
WHERE ROWNUM <= 1;



