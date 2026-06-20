# Dashboard Guide

## Overview

This dashboard provides an interactive analysis of e-commerce sales, profitability, customer behavior, product performance, order activity, and delivery efficiency.

The report consists of five pages:

* Business Overview
* Customer Analysis
* Order Analysis
* Product Analysis
* Delivery Analysis

The dashboard is designed for interactive exploration using page navigation, drill through functionality, cross-filtering, and year-based filtering.

---

## Navigation

All pages can be accessed through the navigation panel located on the left side of the dashboard.

![Navigation Panel](images/Navigation%20Panel.png)

### Active Page Indicator

The currently active page is highlighted in blue within the navigation panel.

For example:

* If the Overview button is highlighted, the Overview page is currently being displayed.
* If the Customers button is highlighted, the Customers page is currently being displayed.

This allows users to easily identify their current location within the dashboard.

### Back Button

A Back button is available on detail pages.

Use the Back button to return to the previous page after exploring customer or product details.

---

## Year Filter

A Year slicer is available within the navigation panel.

Available selections:

* 2023
* 2024
* 2025

The selected year filter is maintained across all dashboard pages.

For example:

* Selecting 2024 on the Overview page automatically applies the same filter when navigating to Customers, Products, Orders, and Delivery pages.
* Users do not need to reselect the year when moving between pages.

This ensures consistent analysis throughout the dashboard.

![Year Slicer](images/Year%20Slicer.png)

---

## Overview Page

Purpose:

Provides a high-level summary of overall business performance.

Key metrics include:

* Total Revenue
* Total Profit
* Total Orders
* Total Customers
* Total Units Sold

This page serves as the starting point for dashboard exploration.

![Business Overview Page](images/Business%20Overview%20Page.png)

---

## Customers Page

Purpose:

Analyzes customer acquisition, purchasing behavior, customer segments, and churn.

Key insights include:

* Customer signups
* Purchasing customers
* Repeat vs One-Time customers
* Revenue contribution by customer segment
* Profit contribution by customer segment
* Customer churn analysis

### Customer Drill through

Customer Details drill through is available through the Churn Analysis visual.

Steps:

1. Right-click a churn category.
2. Select **Drill through → Customer Drill through**.
3. Review customer-level details for the selected churn segment.
4. Use the Back button to return.

![How to Drill through on Customers Page](images/Customer%20Drill%20through%20Guide.png)

After selecting Drill through, the Customer Details page will open and display customers belonging to the selected churn category.

 ![Customer Drill through Page](images/Customer%20Drill%20through%20Page.png)

---

## Products Page

Purpose:

Analyzes product performance across revenue, profit, profitability, and discounting.

Available product segments:

* High Revenue
* High Profit
* High Profit Margin
* Discount Risk

### Product Details Navigation

The Product Details page provides detailed information about products belonging to different performance segments.

Steps:

1. Select a segment from the **Product Segment** slicer:

   * High Revenue
   * High Profit
   * High Profit Margin
   * Discount Risk
2. Click the corresponding KPI card to navigate to the Product Details page.
3. On the Product Details page, select the required segment from the Product Segment slicer.
4. Review the product-level details displayed for the selected segment.
5. Use the Back button to return to the Products page.

Note:

The Product Details page uses a custom navigation approach rather than native Power BI Drill through.

The selected product segment is not automatically carried over when navigating from a KPI card. After opening the Product Details page, users must select the required segment from the Product Segment slicer to view the corresponding products.


![How to Drill through on Products Page](images/Products%20Drill%20through%20Guide.png)

![Products Detail Slicer](images/Products%20Segment%20Slicer.png)

![Product Details Page](images/Product%20Drill%20through%20Page.png)
---

## Orders Page

Purpose:

Analyzes order activity and payment behavior.

Key insights include:

* Order trends
* Revenue trends
* Profit trends
* Payment method analysis
* Order value analysis

Selecting values in charts automatically filters related visuals on the page.

![Orders Analysis Page](images/Orders%20Analysis%20Page.png)

---

## Delivery Page

Purpose:

Analyzes delivery performance and operational efficiency.

Key insights include:

* Fast Deliveries
* Standard Deliveries
* Delayed Deliveries
* City-Level Delivery Performance

Selecting values in visuals automatically updates related charts and metrics.

![Delivery Analysis Page](images/Delivery%20Analysis%20Page.png)

---

## Interactive Features

### Cross Filtering

Most visuals support cross-filtering.

Selecting values in one visual automatically updates related visuals on the same page.

### Customer Drill through

Available through churn categories on the Customers page.

### Product Navigation

Available through KPI cards after selecting a Product Segment.

### Persistent Year Filter

The selected year remains applied while navigating between dashboard pages.

### Back Button

Available on detail pages for returning to the previous page.

---

## Recommended Dashboard Flow

1. Start with the Overview page.
2. Explore customer behavior through the Customers page.
3. Analyze product performance through the Products page.
4. Review order activity through the Orders page.
5. Evaluate operational efficiency through the Delivery page.
