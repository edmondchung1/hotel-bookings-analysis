# Hotel Booking Demand Analysis

**Tools:** MySQL, Tableau
**Data:** 119,205 bookings | City Hotel and Resort Hotel | 2015-2017  
**Source:** [Hotel Booking Demand - Kaggle](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand)
**Tableau:**  https://public.tableau.com/app/profile/edmond.chung6387/viz/Book1_17563614181970/HotelBookingDemandAnalysis20152017?publish=yes&showOnboarding=true

---

This project investigates a 37% cancellation rate across 119,205 hotel bookings to identify where revenue is being lost and what operational changes could recover it.

---

## Overview

This project analyzes hotel booking data to identify the key drivers behind a 37% cancellation rate and quantify the revenue impact across two hotel properties. The goal was to go beyond surface level metrics and find patterns that could inform management decisions around pricing, deposit policy, and channel strategy.

---

## Objectives

- Identify which booking channels and customer segments drive the most cancellations
- Measure how much revenue is being lost to cancellations by hotel type
- Understand how lead time relates to cancellation behavior
- Analyze seasonal Average Daily Rate (ADR) trends across both hotel types
- Determine which customer segments generate the most value per booking

---

## Data Cleaning

Before running any analysis the dataset was cleaned in MySQL to make sure the results were accurate.

- Removed rows with negative ADR values (invalid revenue entries)
- Removed bookings with zero guests recorded (data entry errors)
- Replaced NULL agent values with 'Unknown' to keep all rows in aggregations
- Created a cleaned view with a calculated total_nights column combining weekend and weekday nights

---

## Key Variable

**Average Daily Rate (ADR)** represents the average revenue earned per occupied room per day and is the primary revenue metric used throughout this analysis.

---

## Key Findings

### Cancellations

- The overall cancellation rate was 37.07% across 119,205 bookings
- Groups had the highest cancellation rate at 61.11% despite accounting for 19,790 bookings
- Online Travel Agency (Online TA) was the largest channel with 56,407 bookings but still canceled at 36.76%
- Direct bookings had one of the lowest cancellation rates at 15.36% with a strong ADR of $115.68
- Guests who canceled booked an average of 144.9 days in advance compared to 80.1 days for guests who actually showed up, nearly double the lead time

### Deposit Type

- Non-refundable bookings had a 99.36% cancellation rate, likely because guests cancel regardless once they know the deposit is gone
- No deposit bookings canceled at 28.40%
- Refundable bookings had the lowest cancellation rate at 22.22%

### Revenue

- City Hotel lost an estimated $3,460,702 in potential ADR revenue to cancellations while keeping $4,887,628
- Resort Hotel lost $1,176,809 while keeping $2,627,944
- Combined, both properties lost over $4.6M in potential revenue across the dataset period

### Seasonality

- City Hotel peaked in May at an average daily rate of $120.69 and dropped to $82.36 in January
- Resort Hotel followed a summer peak pattern with rates climbing through July and August
- Both hotels show a clear off-season in January and February which presents a pricing opportunity

### Guest Behavior

- Contract customers generated the highest revenue per booking at $528.84 on average with an average stay of 6.2 nights
- Transient customers made up the majority of bookings at 52,982 but averaged only 3.4 nights per stay at $364.82 per booking
- Group customers had the lowest revenue per booking at $239.00 and the shortest average stay at 2.8 nights

---

## Recommendations

**Tighten cancellation policies for high-risk channels.**
Groups and Online Travel Agencies combined account for over 76,000 bookings but cancel at 61.11% and 36.76% respectively. Introducing non-refundable deposit requirements or shorter cancellation windows for these segments could directly reduce the $4.6M in potential revenue being lost and improve overall booking reliability.

**Use lead time as an early warning signal.**
Canceled bookings were made an average of 144.9 days in advance compared to 80.1 days for guests who showed up. Guests booking more than 90 days out are statistically higher risk. Sending automated confirmation reminders at 60 and 30 days before arrival or requiring a partial deposit for long lead bookings could convert a portion of those cancellations into actual stays.

**Invest in growing the Contract customer segment.**
Contract customers represent only 2,810 bookings but generate $528.84 in average revenue per booking, the highest of any segment and nearly 45% more than Transient customers at $364.82. They also stay an average of 6.2 nights compared to 3.4 nights for Transient customers. Expanding corporate partnerships and direct contract agreements could meaningfully shift the revenue mix toward higher value longer stay bookings without relying on high-cancellation third party channels.

---

## Repository Structure

```
hotel-bookings-analysis/
├── sql/
│   └── hotel_queries.sql
├── tableau/
│   └── hotel_dashboard.twbx
│   └── dashboard_screenshots.png
├── images/
│   └── query screenshots
├── data/
│   └── hotel_bookings.csv
└── README.md
```
