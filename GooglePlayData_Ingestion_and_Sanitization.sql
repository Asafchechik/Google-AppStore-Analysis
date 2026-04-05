-- 1. Initialize raw staging table schema for data ingestion
CREATE TABLE [dbo].[GooglePlayStore_Raw] (
    [App_Name] NVARCHAR(MAX),
    [App_Id] NVARCHAR(MAX),
    [Category] NVARCHAR(MAX),
    [Rating] NVARCHAR(MAX),
    [Rating_Count] NVARCHAR(MAX),
    [Installs] NVARCHAR(MAX),
    [Minimum_Installs] NVARCHAR(MAX),
    [Maximum_Installs] NVARCHAR(MAX),
    [Free] NVARCHAR(MAX),
    [Price] NVARCHAR(MAX),
    [Currency] NVARCHAR(MAX),
    [Size] NVARCHAR(MAX),
    [Minimum_Android] NVARCHAR(MAX),
    [Developer_Id] NVARCHAR(MAX),
    [Developer_Website] NVARCHAR(MAX),
    [Developer_Email] NVARCHAR(MAX),
    [Released] NVARCHAR(MAX),
    [Privacy_Policy] NVARCHAR(MAX),
    [Last_Updated] NVARCHAR(MAX),
    [Content_Rating] NVARCHAR(MAX),
    [Ad_Supported] NVARCHAR(MAX),
    [In_App_Purchases] NVARCHAR(MAX),
    [Editors_Choice] NVARCHAR(MAX),
    [Scraped_Time] NVARCHAR(MAX)
);

-- 2. Bulk load raw CSV data into staging table with UTF-8 support
BULK INSERT [dbo].[GooglePlayStore_Raw]
FROM 'C:\Users\מחשב שלי\Downloads\archive (2)\Google-Playstore.csv' 
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a', 
    FIRSTROW = 2,           
    CODEPAGE = '65001',     
    TABLOCK
);

-- 3. Sample check to verify data ingestion
SELECT TOP 100 * FROM [dbo].[GooglePlayStore_Raw];

-- 4. Create analytical view: Transform raw strings into structured types
CREATE OR ALTER VIEW v_GooglePlayStore_Cleaned AS
SELECT 
    App_Name,
    App_Id, 
    Category,
    -- Cast numerical values for statistical analysis
    TRY_CAST(Rating AS FLOAT) AS Rating,
    TRY_CAST(Rating_Count AS BIGINT) AS Rating_Count,
    -- Sanitize and cast install strings into numeric format
    TRY_CAST(REPLACE(REPLACE(Installs, '+', ''), ',', '') AS BIGINT) AS Installs_Numeric,
    TRY_CAST(Minimum_Installs AS BIGINT) AS Minimum_Installs,
    TRY_CAST(Maximum_Installs AS BIGINT) AS Maximum_Installs,
    -- Convert string-based booleans into binary flags (1/0)
    CASE WHEN Free = 'True' THEN 1 ELSE 0 END AS Is_Free,
    TRY_CAST(Price AS FLOAT) AS Price,
    Currency,
    Size,
    Minimum_Android,
    Developer_Id,
    Developer_Website,
    Developer_Email,
    Released,
    Privacy_Policy,
    -- Extract update year for time-series and stagnation analysis
    TRY_CAST(RIGHT(RTRIM([Last_Updated]), 4) AS INT) AS Last_Updated_Year, 
    Content_Rating,
    -- Map feature flags for monetization and reach analysis
    CASE WHEN Ad_Supported = 'True' THEN 1 ELSE 0 END AS Is_Ad_Supported,
    CASE WHEN In_App_Purchases = 'True' THEN 1 ELSE 0 END AS Has_In_App_Purchases,
    CASE WHEN Editors_Choice = 'True' THEN 1 ELSE 0 END AS Is_Editors_Choice,
    Scraped_Time
FROM [dbo].[GooglePlayStore_Raw]
WHERE 
    -- Logical filters: Exclude outliers, null ratings, and invalid categories
    TRY_CAST(Rating AS FLOAT) BETWEEN 0 AND 5 
    AND Category NOT LIKE '%[0-9]%'
    AND TRY_CAST(REPLACE(REPLACE(Installs, '+', ''), ',', '') AS BIGINT) > 0;