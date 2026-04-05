
# Google Play Store Market Analytics (SQL)
**Advanced SQL Portfolio | Data Integrity & Monetization Strategy**

---

## 🚀 Overview
This project performs a deep-dive analysis of the Google Play Store ecosystem, processing approximately 1.2 million app records. The objective is to extract actionable business intelligence regarding market share, user engagement, and the impact of monetization models on product performance using complex SQL logic.

---

## 🛠 Tech Stack
* **Language:** SQL (SQL Server).
* **Advanced Features:** CTEs, Analytical Window Functions, Multi-factor Aggregations.
* **Data Sanitization:** Pattern matching (`LIKE`), string manipulation, and logical type conversion.

---

## 📊 Key Technical Implementations

### 1. Advanced Analytical Modeling
* **Market Share Distribution:** Developed **CTEs** and global aggregations to calculate the percentage share of installs across diverse categories.
* **Competitive Ranking:** Utilized **Window Functions** (`ROW_NUMBER` with `PARTITION BY`) to rank top-performing apps within each category based on rating count and engagement.
* **Engagement Intensity Index:** Developed a complex ratio of `Rating_Count` to `Total_Installs` using **`NULLIF`** and **`SUM`** to identify the most "vocal" user bases.

### 2. Data Sanitization & Integrity
* **String-to-Numeric Transformation:** Applied **`REPLACE`**, **`CASE WHEN`**, and **`TRY_CAST`** logic to sanitize inconsistent "App Size" strings (e.g., converting 'M' and 'k' suffixes) into numerical buckets.
* **Stagnation Audit:** Built a robust filtering system using **`LIKE`** patterns to identify apps that have not been updated since 2021, quantifying market "stale rates."

---

## 💡 Critical Insights

* **Market Stagnation:** Identified a high stagnation rate (60%+) in categories like Comics and Casino, revealing significant market gaps for updated competitors.
* **The Size-to-Satisfaction Threshold:** Discovered that user ratings peak for "Large" apps (20-100MB) but drop sharply for "Huge" apps (>100MB), indicating a performance penalty for excessive file sizes.
* **Monetization Signals:** Analyzed **In-App Purchase (IAP)** models, finding that apps with IAP consistently outscore free-only models in categories like Music and Racing.
* **The "Editor's Choice" Edge:** Featured apps demonstrate a clear competitive edge, securing higher user satisfaction and a 25% increase in average installs compared to non-featured counterparts.

---

## 📫 Contact & Professional Links
* **Name:** Asaf Chechik
* **LinkedIn:** [Asaf Chechik Portfolio](https://www.linkedin.com/in/asaf-chechik-737a62204/)
* **Email:** Asafchechik9@gmail.com
* **Phone:** 054-7310632
