/*============================================================*/
/*      Watercolor Paintings Database — Analysis Questions	  */
/*============================================================*/


---------------------------------------------------------------
-- 1. Where did all my paintings go?  
-- Breakdown of all paintings by status (counts + %)
---------------------------------------------------------------

-- STATUS						#	%
-- Sold							91	40.1%
-- For Sale						75	33.0%
-- Gifted or Donated			22	9.7%
-- Trashed or Destroyed			16	7.0%
-- Unfinished or In Progress	14	6.2%
-- Not for Sale					9	4.0%

SELECT
  p.status,
  st.Description AS status_description,
  COUNT(*) AS painting_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM paintings), 1) AS pct_of_total
FROM paintings p
LEFT JOIN status st
  ON st.Status = p.status
GROUP BY p.status, st.Description
ORDER BY painting_count DESC;


---------------------------------------------------------------
-- 2. How many paintings were purchased by my family members? 
-- ie. Is my mom my biggest collector? 
---------------------------------------------------------------

-- total paintings sold = 95
-- number of paintings purchased by family members: 19 
-- percent purchased by family members: 20

WITH sold AS (
  SELECT purchased_by
  FROM sales
  WHERE sale_type = 'Sold'
    AND purchased_by IS NOT NULL
    AND TRIM(purchased_by) <> ''
)
SELECT
  SUM(
    CASE
      WHEN lower(purchased_by) LIKE '%lee%'
        OR lower(purchased_by) LIKE '%cherry%'
        OR lower(purchased_by) LIKE '%maestri%'
      THEN 1 ELSE 0
    END
  ) AS family_sales,
  COUNT(*) AS total_sales,
  ROUND(100.0 * SUM(
    CASE
      WHEN lower(purchased_by) LIKE '%lee%'
        OR lower(purchased_by) LIKE '%cherry%'
        OR lower(purchased_by) LIKE '%maestri%'
      THEN 1 ELSE 0
    END
  ) / COUNT(*), 1) AS pct_family
FROM sold;


---------------------------------------------------------------
-- 3. How many of my paintings were sold at art shows vs from home?
-- and % of sold paintings sold at shows vs from home
---------------------------------------------------------------

--  METHOD			#	%
--  Sold at show	73	76.8%
--  Sold by me		22	23.2%

WITH sold AS (
  SELECT *
  FROM sales
  WHERE sale_type = 'Sold'
)
SELECT
  CASE 
	  WHEN show_id IS NULL THEN 'Sold by me' 
	  ELSE 'Sold at show' 
	  END AS channel,
  COUNT(*) AS sold_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sold), 1) AS pct_of_sold
FROM sold
GROUP BY channel
ORDER BY sold_count DESC;


---------------------------------------------------------------
-- 4. Which shows have sold the most paintings?
-- % of paintings sold at each show (grouping same show across years)
---------------------------------------------------------------

-- SHOW														#	%
-- Solo Art Show											35	48%
-- "All in the Family" Art Show								19	26%
-- Arts & the Park Light on the Reef Plein Air Competition	10	14%
-- Midway Plein Air Festival								8	11%
-- Utah Watercolor Society Small Works Exhibition			1	1%

WITH sold_at_shows AS (
  SELECT
    show_name, painting_id
  FROM sales
  WHERE sale_type = 'Sold'
    AND show_id IS NOT NULL
),
totals AS (
  SELECT COUNT(*) AS total_sold_at_shows
  FROM sold_at_shows
)
SELECT
  show_name,
  COUNT(*) AS sold_count,
  ROUND(100.0 * COUNT(*) / (SELECT total_sold_at_shows FROM totals), 0) AS pct_of_show_sales
FROM sold_at_shows
GROUP BY show_name
ORDER BY sold_count DESC;


---------------------------------------------------------------
-- 5. In which month of the year do I paint the most?
-- Painting production by month of year (based on date_started)
---------------------------------------------------------------

-- COUNT	%		SEASON
-- 47		21% 	October
-- 33		15%		June
-- 29		13%		November
-- 22		10%		September
-- 19		8%		March
-- 14		6%		May
-- 14		6%		April
-- 13		6%		July
-- 13		6%		February
-- 11		5%		January
-- 6		3%		December
-- 6		3%		August	

WITH started AS (
  SELECT CAST(strftime('%m', date_started) AS INTEGER) AS month_num
  FROM paintings
  WHERE date_started IS NOT NULL
),
totals AS (
  SELECT COUNT(*) AS total_started
  FROM started
)
SELECT
  month_num,
  COUNT(*) AS paintings_started,
  ROUND(100.0 * COUNT(*) / (SELECT total_started FROM totals), 0) AS pct_of_all_started
FROM started
GROUP BY month_num
ORDER BY paintings_started DESC;


---------------------------------------------------------------
-- 6. Which made me wonder about which season I paint the most?:
---------------------------------------------------------------

-- COUNT	%		SEASON
-- 98		43%		Fall/Autumn (Sep-Nov)
-- 52		23%		Summer (Jun-Aug) 
-- 47		21%		Spring (Mar-May)
-- 30		13%		Winter (Dec-Feb)	

WITH started AS (
  SELECT CAST(strftime('%m', date_started) AS INTEGER) AS month_num
  FROM paintings
  WHERE date_started IS NOT NULL
),
seasoned AS (
  SELECT
    CASE
      WHEN month_num IN (12, 1, 2) THEN 'Winter'
      WHEN month_num IN (3, 4, 5) THEN 'Spring'
      WHEN month_num IN (6, 7, 8) THEN 'Summer'
      ELSE 'Fall'
    END AS season
  FROM started
),
totals AS (
  SELECT COUNT(*) AS total_started
  FROM seasoned
)
SELECT
  season,
  COUNT(*) AS paintings_started,
  ROUND(100.0 * COUNT(*) / (SELECT total_started FROM totals), 0) AS pct_of_all_started
FROM seasoned
GROUP BY season
ORDER BY paintings_started DESC;


---------------------------------------------------------------
-- 7. Best months of the year for sales (count + revenue + avg price)
-- In which month of the year do I sell the most paintings?
---------------------------------------------------------------

-- MONTH		COUNT	%	GROSS		AVE
-- November		29		31%	$4765.00	$164.31
-- October		30		32%	$3090.00	$103.00
-- December		10		11%	$1600.00	$160.00
-- February		10		11%	$1125.00	$112.50
-- September	8		8%	$990.00		$123.75
-- July			5		5%	$575.00		$115.00
-- June			2		2%	$450.00		$225.00
-- January		1		1%	$120.00		$120.00

WITH sold AS (
  SELECT
    CAST(strftime('%m', "date") AS INTEGER) AS month_num,
    amount
  FROM sales
  WHERE sale_type = 'Sold'
    AND "date" IS NOT NULL
),
totals AS (
  SELECT COUNT(*) AS total_sold
  FROM sold
)
SELECT
  month_num,
  COUNT(*) AS sold_count,
  ROUND(100.0 * COUNT(*) / (SELECT total_sold FROM totals), 0) AS pct_of_sold,
  SUM(amount) AS gross_revenue,
  ROUND(AVG(amount), 2) AS avg_sale_price
FROM sold
GROUP BY month_num
ORDER BY gross_revenue DESC;


---------------------------------------------------------------
-- 8.  In which season of the year do I sell the most?
---------------------------------------------------------------

-- SEASON	COUNT	%		GROSS			AVE
-- Fall		67		70.5%	$8845.00		$132.01
-- Winter	21		22.1%	$2845.00		$135.48
-- Summer	7		7.4%	$1025.00		$146.43
-- Spring	0		0%		$0				$0

WITH sold AS (
  SELECT
    CAST(strftime('%m', "date") AS INTEGER) AS month_num,
    amount
  FROM sales
  WHERE sale_type = 'Sold'
    AND "date" IS NOT NULL
),
seasoned AS (
  SELECT
    CASE
      WHEN month_num IN (12, 1, 2) THEN 'Winter'
      WHEN month_num IN (3, 4, 5) THEN 'Spring'
      WHEN month_num IN (6, 7, 8) THEN 'Summer'
      ELSE 'Fall'
    END AS season,
    amount
  FROM sold
),
totals AS (
  SELECT COUNT(*) AS total_sold
  FROM seasoned
)
SELECT
  season,
  COUNT(*) AS sold_count,
  ROUND(100.0 * COUNT(*) / (SELECT total_sold FROM totals), 1) AS pct_of_sold,
  SUM(amount) AS gross_revenue,
  ROUND(AVG(amount), 2) AS avg_sale_price
FROM seasoned
GROUP BY season
ORDER BY gross_revenue DESC;


---------------------------------------------------------------
-- 9. Who are my Top collectors?
---------------------------------------------------------------

-- Lee, Roland				11	1320.0	120.0
-- Anthony, Vern			5	540.0	108.0
-- Carrol, Katy				4	765.0	191.25
-- Thayne, Tim & Roxanne	3	545.0	181.67
-- Pyper, Chris				3	450.0	150.0
-- Olsen, Lisa				3	360.0	120.0
-- McChesney, Betsy 		3	360.0	120.0
-- Madsen, Connie			3	375.0	125.0
-- Cherry, Jana				3	335.0	111.67
-- Smith, Mike & Marcia		2	680.0	340.0
-- Lee, Christian			2	100.0	50.0
-- Keetch, Krista			2	100.0	50.0
-- Hughes, Steve & Whitney	2	220.0	110.0
-- Harward, Katie			2	220.0	110.0
-- Forest, Luanne			2	240.0	120.0
-- Christofferson, Mike		2	395.0	197.5
-- Allen, Matt				2	240.0	120.0
-- Aikens, Barbara			2	275.0	137.5

SELECT
  purchased_by,
  COUNT(*) AS paintings_bought,
  SUM(amount) AS total_spent,
  ROUND(AVG(amount), 2) AS avg_price
FROM sales
WHERE sale_type = 'Sold'
  AND purchased_by IS NOT NULL
  AND TRIM(purchased_by) <> ''
GROUP BY purchased_by
ORDER BY paintings_bought DESC
LIMIT 20;


---------------------------------------------------------------
-- 10. Which words show up the most in sold painting titles?
---------------------------------------------------------------

-- capitol		7
-- reef			6
-- zion			5
-- tree			5
-- study		5
-- old			4
-- morning		4
-- barn			4
-- vista		3
-- shadows		3
-- reflections	3
-- point		3
-- light		3
-- falls		3
-- color		3
-- autumn		3

WITH RECURSIVE
cleaned AS (
  SELECT
    sku,
    lower(
      replace(replace(replace(replace(replace(title, ',', ''), '.', ''), ':', ''), ';', ''), '-', ' ')
    ) AS t
  FROM paintings
  WHERE title IS NOT NULL AND TRIM(title) <> '' AND status = "SO"
),
words(sku, word, rest) AS (
  SELECT sku, '', t || ' ' FROM cleaned
  UNION ALL
  SELECT
    sku,
    substr(rest, 1, instr(rest, ' ') - 1) AS word,
    ltrim(substr(rest, instr(rest, ' ') + 1)) AS rest
  FROM words
  WHERE rest <> ''
)
SELECT
  word,
  COUNT(*) AS occurrences
FROM words
WHERE word IS NOT NULL
  AND TRIM(word) <> ''
  AND LENGTH(word) >= 3
  AND word NOT IN ('the','and','for','with','from','over','into','near','this','that','at','of','in','on','to','a')
GROUP BY word
ORDER BY occurrences DESC
LIMIT 100;


---------------------------------------------------------------
-- 11. Which locations/subjects have I painted the most?
---------------------------------------------------------------

-- Capitol Reef, Utah					61	27%
-- Zion National Park, Utah				24	11%
-- Midway, Utah							14	6%
-- Mt. Carmel, Utah						14	6%
-- Hurricane, Utah						6	3%
-- St. George, Utah 					5	2%
-- Mt. Nebo, Utah						4	2%
-- Cedar City, Utah 					2	1%
-- Bryce Canyon National Park, Utah		2	1%
-- American Fork Canyon, Utah			2	1%

SELECT
  location,
  COUNT(*) AS painting_count
FROM paintings
WHERE location IS NOT NULL AND TRIM(location) <> ''
GROUP BY location
ORDER BY painting_count DESC
LIMIT 50;


---------------------------------------------------------------
-- 12. Do I paint more horizontal or vertical paintings?
---------------------------------------------------------------

-- vert		134		59%
-- horiz	93		41%

SELECT
  format,
  COUNT(*) AS painting_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM paintings), 0) AS pct
FROM paintings
WHERE format IS NOT NULL AND TRIM(format) <> ''
GROUP BY format
ORDER BY painting_count DESC;


---------------------------------------------------------------
-- 13. What size painting do I paint most often?
---------------------------------------------------------------

-- Small (<80 in²)			178		81%
-- Medium (80–199 in²)		47		21%
-- Large (200–399 in²)		2		1%

WITH sized AS (
  SELECT
    sku,
    title,
    image_width,
    image_height,
    (image_width * image_height) AS area_sq_in
  FROM paintings
  WHERE image_width IS NOT NULL AND image_height IS NOT NULL
),
bucketed AS (
  SELECT
    *,
    CASE
      WHEN area_sq_in <  80 THEN 'Small (<80 in²)'
      WHEN area_sq_in < 200 THEN 'Medium (80–199 in²)'
      WHEN area_sq_in < 400 THEN 'Large (200–399 in²)'
      ELSE 'XL (400+ in²)'
    END AS size_bucket
  FROM sized
)
SELECT
  size_bucket,
  COUNT(*) AS painting_count
FROM bucketed
GROUP BY size_bucket
ORDER BY painting_count DESC;


---------------------------------------------------------------
-- 14. Sales trends by year
---------------------------------------------------------------

-- YEAR	#PAINTED	#SOLD	GROSS
-- 2018	42			5		$400
-- 2019	59			41		$6,035
-- 2020	4			1		$120
-- 2021	22			3		$875
-- 2022	9			3		$0
-- 2023	10			3		$260
-- 2024	33			30		$3,990
-- 2025	48			9		$1,035

WITH sales_year AS (
  SELECT
    year AS sale_year,
    COUNT(*) AS sold_count,
    SUM(amount) AS gross_revenue,
    ROUND(AVG(amount), 2) AS avg_sale_price
  FROM sales
  WHERE sale_type = 'Sold'
    AND year IS NOT NULL
  GROUP BY year
),
paint_year AS (
  SELECT
    CAST(strftime('%Y', date_started) AS INTEGER) AS paint_year,
    COUNT(*) AS paintings_started
  FROM paintings
  WHERE date_started IS NOT NULL
  GROUP BY CAST(strftime('%Y', date_started) AS INTEGER)
)
SELECT
  py.paint_year,
  py.paintings_started,
  sy.sold_count,
  sy.gross_revenue,
  sy.avg_sale_price
FROM paint_year py
FULL OUTER JOIN sales_year sy
  ON sy.sale_year = py.paint_year
ORDER BY py.paint_year;


---------------------------------------------------------------
-- 15. Do certain sizes sell better? (by frame_size)
---------------------------------------------------------------
-- FRAME	#MADE	#SOLD	SOLD%	AVG_PRICE	GROSS
-- 8x10		130		67		52		$113.96		$7635.00
-- 12x16	67		18		27		$177.78		$3200.00
-- 16x20	15		3		20		$333.33		$1000.00
-- 5x7		12		5		42		$55.00		$275.00
-- 20x28	2		1		50		$560.00		$560.00
-- 6x8		1		1		100		$45.00		$45.00

WITH produced AS (
  SELECT
    frame_size,
    COUNT(*) AS produced_count
  FROM paintings
  WHERE frame_size IS NOT NULL AND TRIM(frame_size) <> ''
  GROUP BY frame_size
),
sold AS (
  SELECT
    p.frame_size,
    COUNT(*) AS sold_count,
    ROUND(AVG(s.amount), 2) AS avg_sale_price,
    SUM(s.amount) AS gross_revenue
  FROM sales s
  JOIN paintings p ON p.sku = s.painting_id
  WHERE s.sale_type = 'Sold'
    AND p.frame_size IS NOT NULL AND TRIM(p.frame_size) <> ''
  GROUP BY p.frame_size
)
SELECT
  pr.frame_size,
  pr.produced_count,
 	so.sold_count AS sold_count,
  ROUND(100.0 * so.sold_count / pr.produced_count, 0) AS sold_pct,
  so.avg_sale_price,
  so.gross_revenue AS gross_revenue
FROM produced pr
LEFT JOIN sold so ON so.frame_size = pr.frame_size
ORDER BY pr.produced_count DESC;


---------------------------------------------------------------
-- 16. Average price per square inch across all sold paintings
---------------------------------------------------------------

-- Average $/sq in: $2.42

WITH sold AS (
  SELECT painting_id, amount
  FROM sales
  WHERE sale_type = 'Sold'
),
joined AS (
  SELECT
    s.amount,
    (p.image_width * p.image_height) AS area_sq_in
  FROM sold s
  JOIN paintings p ON p.sku = s.painting_id
  WHERE p.image_width IS NOT NULL AND p.image_height IS NOT NULL
    AND (p.image_width * p.image_height) > 0
)
SELECT
  ROUND(SUM(amount) / SUM(area_sq_in), 4) AS dollars_per_sq_in
FROM joined;

