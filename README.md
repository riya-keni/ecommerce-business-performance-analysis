# E-Commerce Business Performance Analysis

## Project Overview

This project analyzes a synthetic e-commerce dataset containing customer, order, product, and delivery information between 2023 and 2025.

Using PostgreSQL and Power BI, the project explores business performance, customer behavior, product profitability, operational efficiency, and revenue drivers through 46 business-focused SQL analyses and an interactive reporting dashboard.

The objective was to simulate a real-world business analytics workflow by transforming raw transactional data into actionable insights for decision-making.

## Objectives

1. Analyze overall business performance using revenue and profitability metrics.
2. Evaluate customer purchasing behavior, retention, and churn.
3. Identify high-value customer segments.
4. Measure product and category performance.
5. Analyze profitability across products and customers.
6. Evaluate delivery performance and operational efficiency.
7. Develop interactive dashboards for business reporting.

## Dataset Overview

The dataset contains:

* 5,000 Orders
* 800 Customers
* 145 Products
* Data from 2023 to 2025

### customers

| Column        |
| ------------- |
| customer_id   |
| customer_name |
| city          |
| signup_date   |

### orders

| Column       |
| ------------ |
| order_id     |
| customer_id  |
| order_date   |
| amount       |
| order_status |
| payment_type |

### products

| Column       |
| ------------ |
| product_id   |
| product_name |
| category     |
| cost_price   |
| price        |

### order_items

| Column     |
| ---------- |
| item_id    |
| product_id |
| order_id   |
| quantity   |
| unit_price |

### delivery

| Column          |
| --------------- |
| delivery_id     |
| order_id        |
| delivery_time   |
| delivery_status |

## Database Schema

![Database Schema](images/ER%20Diagram.png)

## Tools Used

* PostgreSQL
* SQL
* pgAdmin 4
* Power BI
* DAX
* VS Code
* Git
* GitHub

## SQL Analysis

The SQL analysis was performed in PostgreSQL and covers  business questions across multiple business areas.

### Business Performance Analysis

* Revenue Analysis
* Profit Analysis
* Profit Margin Analysis
* Average Order Value (AOV)
* Revenue Growth Analysis
* Seasonal Trends
* KPI Analysis

### Customer Analytics

* Customer Segmentation
* Repeat vs One-Time Customers
* Customer Retention Analysis
* Customer Churn Analysis
* Cohort Analysis
* Customer Profitability Analysis
* Spending Behavior Analysis

### Product Analytics

* Product Performance Analysis
* Product Ranking
* Product Affinity Analysis
* Category Performance Analysis
* Revenue Contribution Analysis

### Profitability Analytics

* Product Profitability Analysis
* Category Profitability Analysis
* Revenue vs Profit Analysis
* Profit Margin Analysis
* Profit Leakage Analysis

### Operational Analytics

* Delivery Performance Analysis
* Delivery Delay Analysis
* Return Analysis
* Cancellation Analysis
* Payment Method Analysis
* City-Level Analysis

## Advanced SQL Concepts Used

* Common Table Expressions (CTEs)
* Window Functions
* RANK()
* DENSE_RANK()
* NTILE()
* LAG()
* CASE Statements
* Aggregate Functions
* Cohort Analysis
* Customer Segmentation
* Churn Analysis
* Retention Analysis
* Product Affinity Analysis

## Power BI Dashboard

The Power BI dashboard was built using imported CSV datasets and custom DAX measures.

Dashboard pages include:

* Business Overview
* Customer Analysis
* Order Analysis
* Product Analysis
* Delivery Analysis

Dashboard features include:

* Interactive page navigation
* Dynamic year filtering (2023–2025)
* Customer drill-through analysis
* Product drill-through analysis
* KPI tracking
* Customer segmentation
* Churn categorization
* Product segmentation
* Revenue and profitability reporting

30+ Custom DAX measures were developed to support revenue analysis, profitability tracking, customer segmentation, retention and churn analysis, discount impact assessment, contribution analysis, and year-over-year performance monitoring.

Key measures included Revenue, Profit, Profit Margin, Average Order Value (AOV), Customer Retention Rate, Revenue Contribution %, Profit Contribution %, Discount %, and various customer and product segmentation metrics.


## Key Insights

### Business Performance

* Generated ₹23.3M in revenue and ₹13.6M in profit from 4,671 delivered orders, resulting in an overall profit margin of 58.43%.
* Average Order Value (AOV) was approximately ₹4,990, indicating a relatively consistent order size across the customer base.
* Several months generated above-average revenue but below-average profitability, highlighting periods where revenue growth did not translate into stronger margins.

### Customer Analysis

* Repeat customers generated approximately 95% of total revenue and profit, making customer retention a major business driver.
* High-spending customers contributed over 84% of total revenue and 86% of total profit, demonstrating strong revenue concentration among a small customer segment.
* A small group of high-spending customers generated more than 80% of total revenue and profit, highlighting customer concentration risk and the importance of retention initiatives.
* The customer retention analysis identified active, warm, at-risk, and churned customer segments using purchase recency.

### Product & Category Analysis

* Kitchen Products generated the highest revenue contribution (25.04%), making it the largest revenue-driving category.
* Personal Care delivered the highest profit contribution (24.00%) and achieved the strongest profit margins, making it the most profitable category.
* Small Appliances generated lower profitability despite significant sales activity and experienced the highest average discounting.
* Small Appliances and Fashion Basics showed the highest profit leakage from product returns.
* Several products generated strong revenue but weak profit margins, highlighting opportunities for pricing and discount optimization.

### Operational & Delivery Analysis

* Cash on Delivery (COD) recorded the highest cancellation and return rates among all payment methods.
* Delivery performance remained relatively consistent across cities, with most locations averaging between 3–5 days.
* Delayed deliveries were associated with significantly higher return rates compared to fast and standard deliveries.
* Standard deliveries represented the largest share of completed deliveries.
* Delayed deliveries were associated with significantly higher return rates than fast and standard deliveries, indicating a potential link between delivery delays and customer dissatisfaction.
### Profitability Analysis

* High-value orders achieved substantially higher profit margins than low-value orders, indicating stronger profitability at larger basket sizes.
* High-spending customers generated the strongest profit margins compared to mid- and low-spending segments.
* Bangalore contributed the largest share of total profit, while cities such as Indore, Lucknow, and Nashik achieved the highest profit margins.
* Personal Care maintained the most stable profit margins over time, while Small Appliances showed the highest margin volatility.

## Skills Demonstrated

### SQL

* Joins
* CTEs
* Window Functions
* Customer Analytics
* Cohort Analysis
* Churn Analysis
* Profitability Analysis
* KPI Analysis

### Power BI

* Data Modeling
* DAX Measures
* Interactive Dashboards
* Drill-Through Reporting
* KPI Design
* Dashboard Navigation

### Business Analytics

* Revenue Analysis
* Customer Segmentation
* Product Analytics
* Profitability Analysis
* Operational Analytics

## Project Structure
``` text
ecommerce-business-performance-analysis/
│
├── ecommerce_project_dataset/
│   ├── customers.csv
│   ├── orders.csv
│   ├── products.csv
│   ├── order_items.csv
│   └── delivery.csv
│
├── images/
│   ├── ER Diagram.png
│   ├── PowerBiBackground.png
│   ├── Business Overview Page.png
│   ├── Customer Analysis Page.png
│   ├── Customer Drillthrough Page.png
│   ├── Order Analysis Page.png
│   ├── Product Analysis Page.png
│   ├── Product Drillthrough Page.png
│   └── Delivery Analysis Page.png
│
├── sql/
│   └── analysis.sql
│
├── power bi/
│   └── Ecommerce_Dashboard.pbix
│
├── README.md
```

## Dashboard Screenshots

### Business Overview

![Business Overview](images/Business%20Overview%20Page.png)


### Customer Analysis

![Customer Analysis](images/Customer%20Analysis%20Page.png)

### Order Analysis

![Order Analysis](images/Orders%20Analysis%20Page.png)

### Product Analysis

![Product Analysis](images/Products%20Analysis%20Page.png)

### Delivery Analysis

![Delivery](images/Delivery%20Analysis%20Page.png)

### Product Drill-through Page

![Product Drillthrough](images/Product%20Drillthrough%20Page.png)

### Customer Drill-through Page

![Customer Drillthrough](images/Customer%20Drillthrough%20Page.png)
