
--Google Play Store Apps Analysis

--1. Market Share Analysis
--Question 1: Which are the top 10 categories by total installs, and what is their percentage share of the total market?

WITH CategoryInstalls AS (
    SELECT 
        Category,
        SUM(Installs_Numeric) AS Total_Category_Installs
    FROM v_GooglePlayStore_Cleaned
    GROUP BY Category
),
GlobalTotal AS (
    SELECT SUM(CAST(Installs_Numeric AS FLOAT)) AS Grand_Total FROM v_GooglePlayStore_Cleaned
)
SELECT TOP 10
    c.Category,
    c.Total_Category_Installs,
    (c.Total_Category_Installs * 100.0 / g.Grand_Total) AS Market_Share_Percent
FROM CategoryInstalls c, GlobalTotal g
ORDER BY c.Total_Category_Installs DESC;

--Business Insight: Identifies which categories dominate the store and where the highest volume of users is concentrated.

--2. Ad-Support vs. User Satisfaction
--Question 2: Compare the average rating and engagement for apps with ads versus those without, categorized by Free and Paid status.

SELECT 
    Is_Free,
    Is_Ad_Supported,
    COUNT(*) AS App_Count,
    AVG(Rating) AS Avg_Rating,
    AVG(CAST(Installs_Numeric AS FLOAT)) AS Avg_Installs
FROM v_GooglePlayStore_Cleaned
GROUP BY Is_Free, Is_Ad_Supported
ORDER BY Is_Free DESC, Is_Ad_Supported DESC;

--Business Insight: Helps determine if aggressive monetization (Ads) significantly negatively impacts user ratings—crucial for Ad-Tech firms.

--3. The "Elite Three" (Window Functions)
--Question 3: For every category, identify the top 3 apps with the highest number of ratings, provided they maintain a rating of at least 4.0.

WITH RankedApps AS (
    SELECT 
        App_Name,
        Category,
        Rating,
        Rating_Count,
        DENSE_RANK() OVER (PARTITION BY Category ORDER BY Rating_Count DESC) AS Rank_In_Category
    FROM v_GooglePlayStore_Cleaned
    WHERE Rating >= 4.0
)
SELECT * FROM RankedApps 
WHERE Rank_In_Category <= 3;

--Business Insight: Competitor benchmarking. It shows who the "monsters" of each niche are that you need to beat.

--4. Engagement Intensity Index
--Question 4: Which categories have the most "vocal" users? (Ratio of Rating Count to Total Installs).


SELECT 
    Category,
    SUM(Rating_Count) AS Total_Ratings,
    SUM(Installs_Numeric) AS Total_Installs,
    (CAST(SUM(Rating_Count) AS FLOAT) / NULLIF(SUM(Installs_Numeric), 0)) * 100 AS Engagement_Ratio
FROM v_GooglePlayStore_Cleaned
GROUP BY Category
HAVING SUM(Installs_Numeric) > 1000000 -- Focus on significant categories
ORDER BY Engagement_Ratio DESC;
--Business Insight: User engagement is driven by category type: immersive entertainment leads in feedback volume, whereas utility apps show lower organic interaction regardless of popularity.

--5. "Stale" vs. "Fresh" Apps Analysis
--Question 5: What percentage of apps in each category have not been updated since 2021?

SELECT 
    Category,
    COUNT(*) AS Total_Apps,
    -- סופרים כמה אפליקציות לא עודכנו מאז 2021
    SUM(CASE 
        WHEN [Last_Updated] LIKE '%2010%' OR [Last_Updated] LIKE '%2011%' OR 
             [Last_Updated] LIKE '%2012%' OR [Last_Updated] LIKE '%2013%' OR 
             [Last_Updated] LIKE '%2014%' OR [Last_Updated] LIKE '%2015%' OR 
             [Last_Updated] LIKE '%2016%' OR [Last_Updated] LIKE '%2017%' OR 
             [Last_Updated] LIKE '%2018%' OR [Last_Updated] LIKE '%2019%' OR 
             [Last_Updated] LIKE '%2020%' 
        THEN 1 ELSE 0 END) AS Stale_Apps,
    -- חישוב האחוז ועיגולו ל-2 ספרות אחרי הנקודה
    ROUND((SUM(CASE 
        WHEN [Last_Updated] LIKE '%2010%' OR [Last_Updated] LIKE '%2011%' OR 
             [Last_Updated] LIKE '%2012%' OR [Last_Updated] LIKE '%2013%' OR 
             [Last_Updated] LIKE '%2014%' OR [Last_Updated] LIKE '%2015%' OR 
             [Last_Updated] LIKE '%2016%' OR [Last_Updated] LIKE '%2017%' OR 
             [Last_Updated] LIKE '%2018%' OR [Last_Updated] LIKE '%2019%' OR 
             [Last_Updated] LIKE '%2020%' 
        THEN 1.0 ELSE 0 END) / COUNT(*)) * 100, 2) AS Stale_Rate_Percent
FROM [dbo].[GooglePlayStore_Raw]
GROUP BY Category
-- הנה השינוי: תראה לי רק קבוצות שיש בהן יותר מ-100 אפליקציות (מסנן את ה-com.)
HAVING COUNT(*) > 100 
ORDER BY Stale_Rate_Percent DESC;

--High stagnation in categories like Comics and Casino (60%+) reveals a massive market gap for new, updated apps to disrupt and replace neglected competition.

--6. Value of Editor's Choice
--Question 6: Does being an "Editor's Choice" actually correlate with more installs and better ratings in the Games category?

SELECT 
    Is_Editors_Choice,
    COUNT(*) AS App_Count,
    AVG(Rating) AS Avg_Rating,
    AVG(CAST(Installs_Numeric AS FLOAT)) AS Avg_Installs
FROM v_GooglePlayStore_Cleaned
WHERE Category IN ('Action', 'Arcade', 'Puzzle', 'Simulation', 'Role Playing', 'Card', 'Casino', 'Board', 'Word', 'Racing', 'Strategy')
GROUP BY Is_Editors_Choice;
--Business Insight: Editor’s Choice apps demonstrate a clear competitive edge, securing higher user satisfaction and a 25% increase in average installs compared to non-featured apps.

--7. High-Performing Developers
--Question 7: Identify developers with more than 5 apps and rank them by their weighted average rating (weighted by installs).

SELECT 
    Developer_Id,
    COUNT(App_Name) AS Total_Apps,
    SUM(Rating * Minimum_Installs) / NULLIF(SUM(Minimum_Installs), 0) AS Weighted_Rating,
    SUM(Minimum_Installs) AS Total_Installs
FROM v_GooglePlayStore_Cleaned
GROUP BY Developer_Id
HAVING COUNT(App_Name) > 5
ORDER BY Weighted_Rating DESC;
--Business Insight: Used for M&A (Mergers and Acquisitions) to find high-quality small studios with consistently great products.

--8. App Size vs. Rating Performance
--Question 8: Does the size of the app impact user ratings? (Segmented into Small, Medium, Large, Huge).

WITH SizeSegmentation AS (
    SELECT 
        Rating,
        CASE 
            WHEN Size LIKE '%k' THEN 'Small (<1MB)'
            WHEN TRY_CAST(REPLACE(Size, 'M', '') AS FLOAT) < 20 THEN 'Medium (1-20MB)'
            WHEN TRY_CAST(REPLACE(Size, 'M', '') AS FLOAT) < 100 THEN 'Large (20-100MB)'
            ELSE 'Huge (>100MB)'
        END AS Size_Bucket
    FROM v_GooglePlayStore_Cleaned
    WHERE Size NOT IN ('Varies with device', 'N/A')
)
SELECT 
    Size_Bucket,
    AVG(Rating) AS Avg_Rating,
    COUNT(*) AS App_Count
FROM SizeSegmentation
GROUP BY Size_Bucket
ORDER BY Avg_Rating DESC;
--Business Insight: Crucial for optimization. If "Huge" apps have lower ratings, it might be due to performance issues on mid-range devices.

--9. In-App Purchase (IAP) Monetization Sentiment
--Question 9: What is the rating difference between apps that offer In-App Purchases and those that don't, across the top 10 categories?

SELECT 
    Category,
    AVG(CASE WHEN Has_In_App_Purchases = 1 THEN Rating ELSE NULL END) AS Avg_Rating_With_IAP,
    AVG(CASE WHEN Has_In_App_Purchases = 0 THEN Rating ELSE NULL END) AS Avg_Rating_No_IAP
FROM v_GooglePlayStore_Cleaned
GROUP BY Category
ORDER BY (AVG(CASE WHEN Has_In_App_Purchases = 1 THEN Rating ELSE NULL END)) DESC;
--Business Insight: Analyzes whether users perceive IAP as "value-add" or "pay-to-win" frustration within specific genres.

--10. Audience Demographics by Installs
--Question 10: Within the top 5 most installed categories, how are installs distributed among Content Ratings (Everyone, Teen, Mature)?
WITH TopCategories AS (
    SELECT TOP 5 Category
    FROM v_GooglePlayStore_Cleaned
    GROUP BY Category
    ORDER BY SUM(Installs_Numeric) DESC
)
SELECT 
    Category,
    Content_Rating,
    SUM(Installs_Numeric) AS Total_Installs,
    SUM(SUM(Installs_Numeric)) OVER (PARTITION BY Category) AS Total_Cat_Installs
FROM v_GooglePlayStore_Cleaned
WHERE Category IN (SELECT Category FROM TopCategories)
AND Content_Rating IN ('Everyone', 'Teen', 'Mature 17+', 'Everyone 10+', 'Adults only 18+', 'Unrated')
GROUP BY Category, Content_Rating
ORDER BY Category, Total_Installs DESC;
--Business Insight: The 'Everyone' rating overwhelmingly dominates installs across all top categories, proving that broad accessibility is the most effective strategy for maximizing market reach.
