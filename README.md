# Watercolor Paintings SQL Analysis

This project analyzes my personal watercolor painting catalog (200+ paintings) using SQLite and SQL. The goal is to combine painting metadata (size, subject, status), show participation, sales, and awards into a small relational database that supports interesting insights about my art practice and art sales performance.

## Project Goals

- Centralize my painting catalog, sales history, show participation, and awards in a relational database.
- Practice SQL skills on a real personal dataset.
- Generate actionable insights such as:
  - Sales trends over time (monthly/yearly)
  - Best-performing shows (revenue + conversion rate)
  - Pricing analysis by size (including $ per square inch)
  - Which subjects/locations sell best
  - Repeat buyer behavior
  - Inventory reporting (for-sale vs sold vs shown vs unshown)

## Database Overview

The database is a SQLite schema designed around a central `paintings` table.

### Tables

- **paintings**
  - One row per painting (authoritative source for painting titles and core metadata).
  - Key fields: `sku`, `status`, `date_started`, `title`, `format`, `image_width`, `image_height`, `frame_size`, `framed_price`, `location`.

- **status**
  - Lookup table describing status codes used in `paintings.status`.
  - Fields: `Status`, `Description`

- **shows**
  - One row per show/event.
  - Fields: `show_id`, `year`, `month`, `show_name`, `show_location`, `notes`

- **show_entries**
  - Join table linking many paintings to many shows.
  - Fields: `show_id`, `painting_id`, `painting_title`
  - Relationship:
    - `show_entries.show_id` → `shows.show_id`
    - `show_entries.painting_id` → `paintings.sku`

- **sales**
  - Transaction table for sold/gifted paintings.
  - Fields: `sale_type`, `date`, `year`, `month`, `purchased_by`, `painting_id`, `amount`, `commission`, plus optional show context (`show_id`, `show_name`, `location`).
  - Relationship:
    - `sales.painting_id` → `paintings.sku`
    - `sales.show_id` → `shows.show_id` (nullable)

- **awards**
  - Awards received at shows (some award rows may contain painting names as a text field).
  - Fields: `id`, `show_id`, `award`, `prize`, `year`, `month`, `notes`
  - Relationship:
    - `awards.show_id` → `shows.show_id`

### Entity Relationships (high level)

- `status (1) → paintings (many)`
- `paintings (many) ↔ shows (many)` via `show_entries`
- `paintings (1) → sales (many)` (usually 0–1 sale, but modeled as many for flexibility)
- `shows (1) → sales (many)` (nullable)
- `shows (1) → awards (many)`

## Example Queries and Key Insights

Below are examples of queries included in this repository (see `/sql/` folder).

### 1) Sales performance over time (gross and estimated net)
Highlights trends by month/year and estimates net revenue if `commission` is stored as a rate (e.g., 0.50 = 50%).

```sql
WITH sold AS (
  SELECT
    year,
    month,
    amount AS gross_amount,
    CASE
      WHEN commission IS NULL THEN 0
      WHEN commission <= 1 THEN commission
      ELSE 0
    END AS commission_rate
  FROM sales
  WHERE sale_type = 'Sold'
),
monthly AS (
  SELECT
    year,
    month,
    COUNT(*) AS sold_count,
    SUM(gross_amount) AS gross_revenue,
    SUM(gross_amount * (1 - commission_rate)) AS net_revenue_est
  FROM sold
  GROUP BY year, month
)
SELECT *
FROM monthly
ORDER BY year, month;
