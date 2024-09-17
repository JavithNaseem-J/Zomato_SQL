
# Zomato Restaurants Data Analysis using SQL


## Overview
This project involves analyzing restaurant data from Zomato using SQL queries. The objective is to uncover insights such as top-rated restaurants, cuisine analysis, price-related trends, and identifying underserved areas where restaurants might need improvement.

## Objectives
- Analyze dining and delivery ratings for restaurants.
- Identify top restaurants by various metrics such as ratings and pricing.
- Determine areas where restaurants perform poorly and need improvement.

## Dataset
The dataset consists of information about restaurants, including details such as location, cuisine, pricing, and customer ratings for both dining and delivery services.

### Schema
- **Restaurant**: Name of the restaurant.
- **Address**: Restaurant’s address.
- **Locations**: The location or area of the restaurant.
- **Cuisine**: Types of cuisines offered by the restaurant.
- **Top_Dishes**: Popular dishes served by the restaurant.
- **Price_for_2**: The price for two people.
- **Dining_Rating**: The restaurant’s rating for dining.
- **Dining_Rating_Count**: Number of reviews/ratings for dining.
- **Delivery_Rating**: The restaurant’s rating for delivery.
- **Delivery_Rating_Count**: Number of reviews/ratings for delivery.
- **Features**: Any additional features of the restaurant (e.g., live music, outdoor seating, etc.).

## Business Problems and Solutions

### 1. Which Restaurants Have the Highest Average Dining Ratings?
```sql
WITH highest_avg AS  (
    SELECT restaurant,
        (dining_rating) AS TOP_DINING,
        RANK() OVER (ORDER BY dining_rating DESC) AS rank
    FROM 
        zomato
    WHERE 
        Dining_rating IS NOT NULL)
SELECT *
FROM highest_avg
WHERE rank = 1;
```
This query identifies the restaurants with the highest dining ratings.

### 2. Identify the Top 5 Restaurants in Each Cuisine Based on Dining Ratings
```sql
WITH RankedRestaurants AS (
    SELECT 
        RESTAURANT,
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
    rank <= 1
ORDER BY 
    DINING_RATING DESC
LIMIT 5;
```
This query lists the top 5 restaurants for each cuisine based on dining ratings.

### 3. Which Restaurants Have a Higher Delivery Rating Compared to Their Dining Rating?
```sql
SELECT 
    RESTAURANT, DINING_RATING, DELIVERY_RATING
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL AND DELIVERY_RATING IS NOT NULL 
    AND DINING_RATING < DELIVERY_RATING
ORDER BY 
    DELIVERY_RATING DESC;
```
This query identifies restaurants where the delivery rating is higher than the dining rating.

### 4. Top 10 Dishes That Lead to Higher Customer Retention
```sql
WITH CTE AS (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(REPLACE(REPLACE(REPLACE(top_dishes, '''', ''), '[', ''), ']', ''), ','))) AS DISHES
    FROM 
        zomato)
SELECT
    DISHES, COUNT(*)
FROM
    CTE
WHERE
    DISHES <> 'Invalid'
GROUP BY
    DISHES
ORDER BY
    COUNT(*) DESC
LIMIT 10;
```
This query lists the top 10 dishes that contribute to higher customer retention.

### 5. Identify the Top 10 Restaurants in Terms of Dining and Delivery Ratings
```sql
-- Top 10 restaurants based on dining ratings
SELECT 
    RESTAURANT, DINING_RATING
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL
ORDER BY 
    DINING_RATING DESC
LIMIT 10;

-- Top 10 restaurants based on delivery ratings
SELECT 
    RESTAURANT, DELIVERY_RATING
FROM 
    ZOMATO
WHERE 
    DELIVERY_RATING IS NOT NULL
ORDER BY 
    DELIVERY_RATING DESC
LIMIT 10;
```
This query lists the top 10 restaurants based on both dining and delivery ratings.

### 6. Identify Underserved Areas Where Restaurants Perform Poorly and Need Improvement
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(LOCATIONS, ',')) AS Location,
    ROUND(AVG(DINING_RATING), 1) AS Avg_Dining_Rating,
    COUNT(*) AS Restaurant_Count
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL 
GROUP BY 
    Location
HAVING 
    AVG(DINING_RATING) < 3.5 
ORDER BY 
    Restaurant_Count DESC;
```
This query identifies locations where restaurants are performing poorly based on dining ratings.

### 7. Which Areas Have the Highest Concentration of Top-Rated Restaurants?
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(LOCATIONS, ',')) AS Location,
    ROUND(AVG(DINING_RATING), 1) AS Avg_Dining_Rating,
    COUNT(*) AS Restaurant_Count
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL 
GROUP BY 
    Location
HAVING 
    AVG(DINING_RATING) >= 4.0 
ORDER BY 
    Avg_Dining_Rating DESC;
```
This query lists areas with the highest concentration of top-rated restaurants.

### 8. Which Top 5 Restaurants Have the Highest Number of Dining and Delivery Rating Counts?
```sql
-- Top 5 restaurants by dining rating count
SELECT 
    RESTAURANT, DINING_RATING, DINING_RATING_COUNT
FROM 
    ZOMATO
WHERE 
    DINING_RATING IS NOT NULL
ORDER BY 
    DINING_RATING_COUNT DESC
LIMIT 5;

-- Top 5 restaurants by delivery rating count
SELECT 
    RESTAURANT, DELIVERY_RATING, DELIVERY_RATING_COUNT
FROM 
    ZOMATO
WHERE 
    DELIVERY_RATING IS NOT NULL
ORDER BY 
    DELIVERY_RATING_COUNT DESC
LIMIT 5;
```
This query lists the top 5 restaurants based on the number of dining and delivery ratings.


### 9.Do higher-priced restaurants (e.g., 1000+ INR) tend to have better ratings compared to lower-priced ones?
```
SELECT
    ROUND(AVG(CASE WHEN PRICE_FOR_2 < 1000 THEN DINING_RATING END), 2) AS DINING_LOWER,
 	ROUND(AVG(CASE WHEN PRICE_FOR_2 > 1000 THEN DINING_RATING END), 2) AS DINING_HIGHER,
	ROUND(AVG(CASE WHEN PRICE_FOR_2 < 1000 THEN DELIVERY_RATING END), 2) AS DELIVERY_LOWER,
 	ROUND(AVG(CASE WHEN PRICE_FOR_2 > 1000 THEN DELIVERY_RATING END), 2) AS DELIVERY_HIGHER
FROM
  ZOMATO;
```

### 10.Are there any locations where the majority of restaurants have lower than average ratings?

```
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
```


## Conclusion
This Zomato dataset analysis highlights key trends in restaurant performance based on customer ratings for both dining and delivery. By identifying top restaurants and underserved areas, businesses can better tailor their services to meet customer needs.
