CREATE DATABASE hotel_bookings;
USE hotel_bookings;

SELECT COUNT(*)
FROM bookings;

-- Data Exploration

-- Query 1 - dataset overview
SELECT
	COUNT(*) AS total_bookings,
    SUM(is_canceled) AS total_cancellations,
    ROUND(AVG(is_canceled) * 100, 2) AS cancellation_rate_pct,
    ROUND(AVG(adr), 2) AS average_daily_rate,
    ROUND(AVG(lead_time), 1) AS avg_lead_time_days,
    MIN(arrival_date_year) AS earliest_year,
    MAX(arrival_date_year) AS latest_year
FROM bookings;

-- Query 2 - checking nulls in key columns
SELECT 'country'  AS column_name, COUNT(*) - COUNT(country)  AS null_count FROM bookings
UNION ALL
SELECT 'agent',   COUNT(*) - COUNT(agent)   FROM bookings
UNION ALL
SELECT 'company', COUNT(*) - COUNT(company) FROM bookings
UNION ALL
SELECT 'children',COUNT(*) - COUNT(children)FROM bookings;

-- Query 3 - how is data split between hotel types
SELECT
    hotel,
    COUNT(*) AS total_bookings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bookings), 2) AS pct_of_total
FROM bookings
GROUP BY hotel
ORDER BY total_bookings DESC;


-- Query 4 - flagging negative adr rows before deleting
SELECT * FROM bookings WHERE adr < 0;

-- Query 5 - duplicate detection
SELECT
    hotel, lead_time, arrival_date_year, arrival_date_month,
    arrival_date_day_of_month, adults, adr,
    COUNT(*) AS occurrences
FROM bookings
GROUP BY
    hotel, lead_time, arrival_date_year, arrival_date_month,
    arrival_date_day_of_month, adults, adr
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 10;

-- Data Cleaning 

-- removing bad rows
SET SQL_SAFE_UPDATES = 0;

-- agent nulls -> unknown
UPDATE bookings
SET agent = 'Unknown'
WHERE agent IS NULL;

-- remove negative adr row
DELETE FROM bookings WHERE adr < 0;

-- remove bookings with no guests
DELETE FROM bookings WHERE adults = 0 AND children = 0 AND babies = 0;

SET SQL_SAFE_UPDATES = 1;

-- create view with cleaned columns + total nights calc
CREATE OR REPLACE VIEW bookings_clean AS
SELECT *,
    COALESCE(agent, 'Unknown') AS agent_clean,
    COALESCE(country, 'Unknown') AS country_clean,
    (stays_in_weekend_nights + stays_in_week_nights) AS total_nights
FROM bookings
WHERE adr >= 0 AND adr < 5000;

-- Cancellation Analysis

-- Query 6 - cancellation rate by hotel type
SELECT
    hotel,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM bookings_clean
GROUP BY hotel
ORDER BY cancel_rate_pct DESC;

-- Query 7 - which market segment cancels the most
SELECT
    market_segment,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct,
    ROUND(AVG(adr), 2) AS avg_daily_rate
FROM bookings_clean
GROUP BY market_segment
ORDER BY cancel_rate_pct DESC;

-- Query 8 - does deposit type affect cancellations
SELECT
    deposit_type,
    COUNT(*) AS bookings,
    SUM(is_canceled) AS canceled,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM bookings_clean
GROUP BY deposit_type
ORDER BY cancel_rate_pct DESC;

-- Query 9 do people who book earlier cancel more
SELECT
    CASE WHEN is_canceled = 1 THEN 'Canceled' ELSE 'Not Canceled' END AS status,
    COUNT(*) AS bookings,
    ROUND(AVG(lead_time), 1) AS avg_lead_time_days
FROM bookings_clean
GROUP BY is_canceled
ORDER BY avg_lead_time_days DESC;

-- Query 10 - cancellations by month to spot seasonal patterns
SELECT
    arrival_date_year AS year,
    arrival_date_month AS month,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM bookings_clean
GROUP BY arrival_date_year, arrival_date_month
ORDER BY arrival_date_year,
    FIELD(arrival_date_month,
        'January','February','March','April','May','June',
        'July','August','September','October','November','December');

-- Revenue Analysis

-- Query 11 - adr by hotel type
SELECT
    hotel,
    ROUND(AVG(adr), 2) AS avg_daily_rate,
    ROUND(MIN(adr), 2) AS min_adr,
    ROUND(MAX(adr), 2) AS max_adr,
    COUNT(*) AS bookings
FROM bookings_clean
WHERE is_canceled = 0
GROUP BY hotel;

-- Query 12 - which months have the highest adr
SELECT
    arrival_date_month AS month,
    ROUND(AVG(adr), 2) AS avg_daily_rate,
    COUNT(*) AS bookings
FROM bookings_clean
WHERE is_canceled = 0
GROUP BY arrival_date_month
ORDER BY avg_daily_rate DESC;

-- Query 13 - where do most guests come from
SELECT
    country_clean AS country,
    COUNT(*) AS bookings,
    ROUND(AVG(adr), 2) AS avg_daily_rate,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM bookings_clean
GROUP BY country_clean
ORDER BY bookings DESC
LIMIT 10;

-- Query 14 - how much revenue did cancellations cost
SELECT
    hotel,
    ROUND(SUM(CASE WHEN is_canceled = 1 THEN adr ELSE 0 END), 2) AS revenue_lost,
    ROUND(SUM(CASE WHEN is_canceled = 0 THEN adr ELSE 0 END), 2) AS revenue_kept
FROM bookings_clean
GROUP BY hotel
ORDER BY revenue_lost DESC;

-- Guest Behavior

-- Query 15 - repeat guests vs new guests
SELECT
    CASE WHEN is_repeated_guest = 1 THEN 'Repeat' ELSE 'New' END AS guest_type,
    COUNT(*) AS bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct,
    ROUND(AVG(adr), 2) AS avg_daily_rate
FROM bookings_clean
GROUP BY is_repeated_guest;

-- Query 16 - do more special requests mean lower cancellation rate
SELECT
    total_of_special_requests AS special_requests,
    COUNT(*) AS bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM bookings_clean
GROUP BY total_of_special_requests
ORDER BY total_of_special_requests;

-- Query 17 - length of stay by customer type
SELECT
    customer_type,
    COUNT(*) AS bookings,
    ROUND(AVG(total_nights), 2) AS avg_nights,
    ROUND(AVG(adr), 2) AS avg_daily_rate
FROM bookings_clean
WHERE is_canceled = 0
GROUP BY customer_type
ORDER BY avg_nights DESC;

-- Query 18 - adr comparison city hotel vs resort month
SELECT
    hotel,
    arrival_date_month AS month,
    ROUND(AVG(adr), 2) AS avg_daily_rate
FROM bookings_clean
WHERE is_canceled = 0
GROUP BY hotel, arrival_date_month
ORDER BY hotel,
    FIELD(arrival_date_month,
        'January','February','March','April','May','June',
        'July','August','September','October','November','December');
        
-- Query 19 - which customer type generates the most revenue per booking
SELECT
    customer_type,
    COUNT(*) AS bookings,
    ROUND(AVG(adr * total_nights), 2) AS avg_revenue_per_booking,
    ROUND(AVG(adr), 2) AS avg_daily_rate,
    ROUND(AVG(total_nights), 1) AS avg_nights
FROM bookings_clean
WHERE is_canceled = 0
GROUP BY customer_type
ORDER BY avg_revenue_per_booking DESC;

-- Query 20 - best market segments by revenue and cancellation combined
SELECT
    market_segment,
    COUNT(*) AS bookings,
    ROUND(AVG(adr), 2) AS avg_daily_rate,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct,
    ROUND(SUM(CASE WHEN is_canceled = 0 THEN adr ELSE 0 END), 2) AS realized_revenue
FROM bookings_clean
GROUP BY market_segment
ORDER BY realized_revenue DESC;
