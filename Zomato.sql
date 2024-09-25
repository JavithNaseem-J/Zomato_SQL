DROP TABLE IF EXISTS ZOMATO;

CREATE TABLE ZOMATO (
    Zomato_URL TEXT,
    Restaurant TEXT,
    Address TEXT,
    Locations TEXT,
    Cuisine TEXT,
    Top_Dishes TEXT,
    Price_for_2 DECIMAL(10, 2),
    Dining_Rating DECIMAL(2, 1),
    Dining_Rating_Count INT,
    Delivery_Rating DECIMAL(2, 1),
    Delivery_Rating_Count INT,
    Features TEXT
);



SELECT *
FROM zomato;


ALTER TABLE zomato
DROP COLUMN Zomato_url;


--1. Which restaurants have the highest average dining ratings?

WITH highest_avg AS  (
    SELECT restaurant,
        (dining_rating) AS TOP_DINING,
        RANK() OVER (ORDER BY dining_rating DESC) AS length_rank
    FROM 
        zomato
	WHERE 
        Dining_rating IS NOT NULL)
SELECT *
FROM highest_avg
WHERE length_rank = 1;

--2.identify the top 5 restaurants in each cuisine based on  dining ratings?

WITH RankedRestaurants AS (
    SELECT 
        RESTAURANT,
		ROW_NUMBER() OVER(PARTITION BY RESTAURANT ORDER BY RESTAURANT) AS RN,
        TRIM(UNNEST(STRING_TO_ARRAY(REPLACE(REPLACE(REPLACE(CUISINE, '''', ''), '[', ''), ']', ''), ','))) AS CUISINE,
        DINING_RATING,
        ROW_NUMBER() OVER (PARTITION BY TRIM(UNNEST(STRING_TO_ARRAY(REPLACE(REPLACE(REPLACE(CUISINE, '''', ''), '[', ''), ']', ''), ','))) ORDER BY DINING_RATING DESC) AS rank
    FROM
        ZOMATO
    WHERE
        DINING_RATING IS NOT NULL)
SELECT 
    RESTAURANT,
    CUISINE,
    DINING_RATING
FROM 
    RankedRestaurants
WHERE 
    rank <= 1 AND RN <= 1
ORDER BY 
   DINING_RATING DESC LIMIT 5;


-- 3.Which restaurants have a higher delivery rating compared to their dining rating?

SELECT 
	RESTAURANT,DINING_RATING,DELIVERY_RATING
FROM
	ZOMATO
WHERE
	DINING_RATING IS NOT NULL AND DELIVERY_RATING IS NOT NULL AND DINING_RATING<DELIVERY_RATING
ORDER BY 
	2 DESC;

-- 4.top 10 dishes that lead to higher customer retention ?

WITH CTE AS (
	SELECT 
	    TRIM(UNNEST(STRING_TO_ARRAY(REPLACE(REPLACE(REPLACE(top_dishes, '''', ''), '[', ''), ']', ''), ','))) AS DISHES
	FROM 
	    zomato)
SELECT
	DISHES,COUNT(*)
FROM
	CTE
WHERE
	DISHES <> 'Invalid'
GROUP BY
	1
ORDER BY
	2 DESC 	limit 10;

--5.identify the top 10 restaurants in terms of dining and delivery ratings?

--top 10 restaurants in terms of dining ratings
SELECT 
    RESTAURANT,
    DINING_RATING
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL
ORDER BY 
    DINING_RATING DESC
LIMIT 10;


--top 10 restaurants in terms of delivery ratings

SELECT 
    RESTAURANT,
    DELIVERY_RATING
FROM 
    ZOMATO
WHERE 
    DELIVERY_RATING IS NOT NULL
ORDER BY 
    DELIVERY_RATING DESC
LIMIT 10;


--6.identify any underserved areas where restaurants perform poorly and need improvement?

SELECT 
    UNNEST(STRING_TO_ARRAY(LOCATIONS,',')),
    ROUND(AVG(DINING_RATING),1) AS Avg_Dining_Rating,
    COUNT(*) AS Restaurant_Count
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL 
GROUP BY 
    LOCATIONS
HAVING 
    AVG(DINING_RATING) < 3.5 
ORDER BY 
    RESTAURANT_COUNT DESC;

--7.Which areas have the highest concentration of top-rated restaurants?
SELECT 
    UNNEST(STRING_TO_ARRAY(LOCATIONS,',')),
    ROUND(AVG(DINING_RATING),1) AS Avg_Dining_Rating,
    COUNT(*) AS Restaurant_Count
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL 
GROUP BY 
    LOCATIONS
HAVING 
    AVG(DINING_RATING) >= 4.0 
ORDER BY 
    avg_dining_rating DESC;

--8.Which top 5 restaurants have the highest number of dining and delivery rating counts?

--highest number of dining rating counts
SELECT 
	RESTAURANT,DINING_RATING, DINING_RATING_COUNT
FROM 
	ZOMATO
WHERE
	DINING_RATING_COUNT IS NOT NULL
ORDER BY 
	DINING_RATING_COUNT DESC
LIMIT 5;

--highest number of delivery rating counts

SELECT 
	RESTAURANT,DELIVERY_RATING, DELIVERY_RATING_COUNT
FROM 
	ZOMATO
WHERE
	DELIVERY_RATING_COUNT IS NOT NULL
ORDER BY 
	DELIVERY_RATING_COUNT DESC
LIMIT 5;

--9.Do higher-priced restaurants (e.g., 1000+ INR) tend to have better ratings compared to lower-priced ones?

SELECT
    ROUND(AVG(CASE WHEN PRICE_FOR_2 < 1000 THEN DINING_RATING END), 2) AS DINING_LOWER,
 	ROUND(AVG(CASE WHEN PRICE_FOR_2 > 1000 THEN DINING_RATING END), 2) AS DINING_HIGHER,
	ROUND(AVG(CASE WHEN PRICE_FOR_2 < 1000 THEN DELIVERY_RATING END), 2) AS DELIVERY_LOWER,
 	ROUND(AVG(CASE WHEN PRICE_FOR_2 > 1000 THEN DELIVERY_RATING END), 2) AS DELIVERY_HIGHER
FROM
  ZOMATO;
  
--10.Are there any locations where the majority of restaurants have lower than average ratings?

WITH CTE1 AS (
	SELECT
		AVG(DINING_RATING) AS AVG_DINING_RATING,AVG(DELIVERY_RATING) AS AVG_DELIVERY_RATING
	FROM
		ZOMATO),
CTE2 AS (
	SELECT
		LOCATIONS,AVG(DINING_RATING) AS LAVG_DINING_RATING,AVG(DELIVERY_RATING) AS LAVG_DELIVERY_RATING
	FROM
		ZOMATO
	GROUP BY
		1)
SELECT
	LOCATIONS,ROUND(LAVG_DINING_RATING,2),ROUND(LAVG_DELIVERY_RATING,2)
FROM
	CTE1,CTE2
WHERE
	CTE1.AVG_DINING_RATING < LAVG_DINING_RATING OR CTE1.AVG_DELIVERY_RATING < LAVG_DELIVERY_RATING;
	
	

