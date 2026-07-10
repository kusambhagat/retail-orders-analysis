# Retail Orders Analysis — SQL + Python

## About the Project
An end-to-end data analysis project where I used Python to clean raw retail orders data
and SQL Server to perform in-depth business analysis. The goal was to uncover revenue trends,
profit patterns, regional performance, and year-over-year growth across product categories.

---

## Tools Used
- Python (pandas, sqlalchemy) - data cleaning and loading
- SQL Server (T-SQL) - business analysis and querying
- Jupyter Notebook
- GitHub

---

## Dataset
- **Source:** Kaggle — Retail Orders Dataset
- **Link:** https://www.kaggle.com/datasets/ankitbansal06/retail-orders
- **Size:** 9,994 orders across multiple US regions, categories, and customer segments

---

## Project Structure

```
retail-orders-analysis/
│
├── orders_analysis.ipynb    — Python script: data cleaning and loading to SQL Server
├── orders_analysis.sql      — SQL queries: business analysis and insights
├── create_star_schema.sql   — DDL script: star schema with primary keys, unique and foreign key constraints
└── README.md                — Project documentation
```

---

## What the Python Script Does
1. Downloads the dataset directly from Kaggle API
2. Handles null values (`Not Available`, `unknown`) on read
3. Standardises all column names to snake_case
4. Derives three new financial columns:
   - `discount` = list price × discount percent
   - `sale_price` = list price after discount
   - `profit` = sale price minus cost price
5. Drops raw columns no longer needed (list_price, cost_price, discount_percent)
6. Loads the cleaned data into SQL Server using SQLAlchemy

---

## Business Questions Answered

| # | Question |
|---|----------|
| 1 | What are the top 10 highest revenue generating products? |
| 2 | What are the top 5 highest selling products in each region? |
| 3 | How did sales compare month over month between 2022 and 2023? |
| 4 | For each category, which month had the highest sales? |
| 5 | Which sub-category had the highest profit growth in 2023 vs 2022? |
| 6 | What is the overall revenue, profit, and profit margin? |
| 7 | What is the average discount given per category? |
| 8 | Are there any states making a loss? |
| 9 | What is each category's percentage contribution to total revenue? |
| 10 | What does the running total of sales look like over time? |
| 11 | Which ship mode is most used per region? |
| 12 | Which products were profitable in 2022 but loss-making in 2023? |
| 13 | What is the year-over-year growth percentage by category? |
| 14 | What are the top 3 most profitable sub-categories per region? |
| 15 | Which customer segment is the most valuable? |
| 16 | Which states are the best performers? |
| 17 | What was the overall sales growth from 2022 to 2023? |

---

## Key Findings

- **Total business overview:** 9,994 orders generated **$2.21M in revenue** and **$205K in profit**,
  with an overall profit margin of **9.26%**

- **Technology leads revenue:** The Technology category was the highest earning segment
  with **$806,873** in total sales — over 36% of all revenue

- **Consumer segment most profitable:** The Consumer segment generated the highest profit
  at **$101,586**, making it the most valuable customer group to the business

- **No loss-making states:** Every single US state in the dataset operated in profit —
  no state had a negative total profit, which signals healthy nationwide distribution

- **Discounts vary by category:** Average discount levels differ across categories,
  suggesting inconsistent pricing strategy that could be optimised to improve margins

  - **Data quality — Ship Mode:** 6 of 9,994 orders (0.06%) had missing Ship Mode
  values disguised as three inconsistent placeholders ("Not Available", "unknown",
  "N/A"), consolidated into a single "Unknown" label during cleaning. Kept as a
  visible category rather than deleted — the orders are real and their revenue
  belongs in totals; only the ship-mode attribute is missing.

- **Data quality — revenue reconciliation:** Rebuilding the analysis in Power BI
  initially produced −10M, then 11M revenue against the SQL pipeline's $2.21M.
  Two root causes found: (1) Discount Percent is stored as whole numbers
  (3 = 3%), not fractions — fixed with /100 in the DAX measure; (2) the measure
  multiplied by Quantity while the SQL pipeline sums sale_price directly.
  Aligned the dashboard to the SQL definition so all published figures
  reconcile to the pound ($2,215,859; Technology $806,873). Open follow-up:
  confirm whether sale_price in the source data represents unit price or
  line total.

---

## SQL Techniques Used
- CTEs (Common Table Expressions)
- Window functions - `DENSE_RANK`, `ROW_NUMBER`, `RANK`, `SUM() OVER()`
- `CASE WHEN` for year-based pivoting (2022 vs 2023 comparisons)
- `PARTITION BY` for regional and category-level rankings
- Running totals using `SUM() OVER(ORDER BY)`
- `HAVING` clause for filtered aggregations
- `NULLIF` to prevent division by zero errors

## How to Run

**Step 1 — Install dependencies**
```bash
pip install -r requirements.txt
```

**Step 2 — Set up Kaggle API**

Download your `kaggle.json` API token from Kaggle → place it in `~/.kaggle/`

**Step 3 — Set up SQL Server**

Create a database in SSMS:
```sql
CREATE DATABASE OrdersAnalysisProject;
```

**Step 4 — Run the notebook**

Open `orders_analysis.ipynb` in Jupyter and run all cells in order.
The dataset will be downloaded automatically via the Kaggle API.

**Step 5 — Run the SQL script**

Open `orders_analysis.sql` in SSMS and run the queries.
