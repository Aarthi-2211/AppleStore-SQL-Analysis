CREATE TABLE appleStore_description_combined AS
SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4


**Exploratory Data Analysis**

-- Check the no. of unique apps in both tablesApplesStore
SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS null

 -- Find out the no. of apps per genre
SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- Get an overview of the apps ratings
SELECT min(user_rating) AS MinRating,
              max(user_rating) AS MaxRating,
              avg(user_rating) AS AvgRating
FROM AppleStore

**Data Analysis**
-- Determine whether paid apps have higher ratings than free apps
SELECT CASE
       WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
END AS App_Type,
avg(user_rating) AS Avg_Rating
FROM AppleStore
Group BY App_Type

-- Check if apps with more supported languages have higher ratings
SELECT CASE
          WHEN lang_num < 10 THEN '< 10 languages'
          WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
ELSE '>30 languages'
END AS language_bucket,
Avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

-- Check genre with low ratings
SELECT prime_genre,
    Avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 5

-- Check if there’s correlation between the length of the app description and the user rating
SELECT CASE
        WHEN length(b.app_desc) < 500 THEN 'Short'
         WHEN length (b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
         ELSE 'Long'
END AS description_length_bucket,
Avg(a.user_rating) AS average_rating
FROM AppleStore AS A
JOIN appleStore_description_combined AS b
ON a.id = b.id
GROUP BY description_length_bucket
ORDER BY average_rating DESC


-- Check the top-rated apps for each genre
SELECT
   prime_genre,
   track_name,
   user_rating
FROM (
    SELECT
        prime_genre,
        track_name,
        user_rating,
        RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
    FROM
        appleStore
) AS a
WHERE
    a.rank = 1;

-- Explore the distribution of prices within each genre
WITH RankedPrices AS (
    SELECT
        prime_genre,
        price,
        ROW_NUMBER() OVER (PARTITION BY prime_genre ORDER BY price) AS RowAsc,
        ROW_NUMBER() OVER (PARTITION BY prime_genre ORDER BY price DESC) AS RowDesc
    FROM AppleStore
)
SELECT
    prime_genre,
    MAX(price) AS Max_Price,
    AVG(price * 1.0) AS Median_Price
FROM RankedPrices
WHERE RowAsc = RowDesc OR RowAsc + 1 = RowDesc OR RowAsc = RowDesc + 1
GROUP BY prime_genre
ORDER BY Median_Price DESC;

-- Investigate the correlation between supported devices and user ratings
SELECT
    sup_devices_num,
    AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY sup_devices_num
ORDER BY sup_devices_num;

-- Examine the trend of user ratings over different versions
SELECT ver, AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY ver
ORDER BY ver;






