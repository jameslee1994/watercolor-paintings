# Watercolor Paintings — SQLite Analysis

## Background
In 2018, I took my first watercolor painting lesson. I set a goal to paint 100 paintings. It was a lot of work, and it took me two years to achieve my goal, but I did it, I liked it, and the hobby stuck. Since then I have painted over 220 paintings (sold nearly 100 of them!), exhibited in a number of professional shows and competitions, and have even received some awards.

Check me out on instagram if you want to see some of my work: https://www.instagram.com/jimleewatercolors/

This project involved putting my personal watercolor painting records into a SQLite database so I could look back on my watercolor journey. The dataset combines painting metadata (title, size, subject/location, status), show participation, sales, and awards so I can answer questions about my painting and sales trends.

All of the analysis queries (and the findings summarized below) live in **`analysis_queries.sql`**.

---

## Project Goals

- Build a small relational database from a real personal dataset.
- Practice practical SQL skills: joins, CTEs, aggregations, etc.
- Understand where my paintings end up (sold / for sale / gifted / trashed / in progress / not for sale).
- Measure sales performance (by channel, show, month/season, year).
- Understand my painting habits (when I paint, what subjects/locations I paint most, orientation, and size distribution).
- Use the insights to guide future painting, pricing, and show decisions.

---

## Database Structure
The database is a SQLite schema designed around a central `paintings` table.

### Tables

- **paintings** - a list of all the paintings I have painted, when I started them, and what size they were.
- **status** - a lookup table for status codes of the current status of each painting, such as "sold", "gifted", "trashed", etc.
- **shows** - a list of art shows, exhibits, and competitions I have participated in.
- **show_entries** - a table linking paintings to the shows they were 
- **sales** — details about the sale of each painting, including buyer, purchase price, etc.
- **awards** — a list of awards that I have received, prize, painting that received it, etc.

### Relationships (high level)

- `status (1) → paintings (many)` via `paintings.status`
- `paintings (many) ↔ shows (many)` via `show_entries`
- `paintings (1) → sales (many)` via `sales.painting_id`
- `shows (1) → sales (many)` via `sales.show_id` (nullable)
- `shows (1) → awards (many)` via `awards.show_id`

## Analysis questions included

1. Where did all my paintings go?
2. How many paintings were purchased by my family members?
3. How many of my paintings were sold at art shows vs from home?
4. Which shows have sold the most paintings?
5. In which month of the year do I paint the most?
6. Which made me wonder about which season I paint the most?:
7. Best months of the year for sales (count + revenue + avg price)
8. In which season of the year do I sell the most?
9. Who are my Top collectors?
10. Which words show up the most in sold painting titles?
11. Which locations/subjects have I painted the most?
12. Do I paint more horizontal or vertical paintings?
13. What size painting do I paint most often?
14. Sales trends by year
15. Do certain sizes sell better? (by frame_size)
16. Average price per square inch across all sold paintings

---

## Highlights & findings (from `analysis_queries.sql`)

### Where did all my paintings go?
Out of **227 total paintings**:

- **Sold:** 91 (**40.1%**)
- **For Sale:** 75 (**33.0%**)
- **Gifted/Donated:** 22 (**9.7%**)
- **Trashed/Destroyed:** 16 (**7.0%**)
- **Unfinished/In Progress:** 14 (**6.2%**)
- **Not for Sale:** 9 (**4.0%**)

### Family support is real
Of **95** recorded sales:
- **19** were purchased by family → **20%** of all sold paintings.

### Shows are the engine of sales
Of those **95** sales:
- **Sold at shows:** 73 (**76.8%**)
- **Sold from home / directly:** 22 (**23.2%**)

### Which shows sold the most?
Share of show-attributed sales (grouped across years):

- **Solo Art Show:** 35 (**48%**)
- **“All in the Family” Art Show:** 19 (**26%**)
- **Arts & the Park / Light on the Reef Plein Air Competition:** 10 (**14%**)
- **Midway Plein Air Festival:** 8 (**11%**)
- **Utah Watercolor Society Small Works Exhibition:** 1 (**1%**)

### When do I paint the most?
Paintings started by month:

- **October:** 47 (**21%**)
- **June:** 33 (**15%**)
- **November:** 29 (**13%**)
- **September:** 22 (**10%**)

By season (meteorological):
- **Fall (Sep–Nov):** 98 (**43%**)
- **Summer (Jun–Aug):** 52 (**23%**)
- **Spring (Mar–May):** 47 (**21%**)
- **Winter (Dec–Feb):** 30 (**13%**)

### When do I sell the most?
By month, my biggest sales months are:
- **October:** 30 sales (**32%**) — **$3,090** gross
- **November:** 29 sales (**31%**) — **$4,765** gross

By season, sales are heavily concentrated in fall:
- **Fall:** 67 sales (**70.5%**) — **$8,845** gross (avg **$132**)
- **Winter:** 21 sales (**22.1%**) — **$2,845** gross (avg **$135**)
- **Summer:** 7 sales (**7.4%**) — **$1,025** gross (avg **$146**)
- **Spring:** 0 sales

### Top collectors
A few repeat buyers show up as true “collectors.” The #1:
- **Roland Lee** — **11** paintings, **$1,320** total (avg **$120**)

(See `analysis_queries.sql` for the full ranked list.)

### What themes show up in sold titles?
Most common words appearing in **sold** painting titles include:
- **capitol**, **reef**, **zion**, **tree**, **study**, **morning**, **barn**, **light**, **autumn**, and more.

This is a nice foundation for a word cloud (and for testing whether certain themes sell faster or for more).

### What do I paint the most?
Top painted locations/subjects:

- **Capitol Reef, Utah:** 61 paintings (**27%**)
- **Zion National Park, Utah:** 24 (**11%**)
- **Midway, Utah:** 14 (**6%**)
- **Mt. Carmel, Utah:** 14 (**6%**)

### Orientation and size: my default style
- **Vertical:** 134 (**59%**)
- **Horizontal:** 93 (**41%**)

Most of my work is small:
- **Small (<80 in²):** 178 (**81%**)
- **Medium (80–199 in²):** 47 (**21%**)
- **Large (200–399 in²):** 2 (**1%**)

### Sales trend by year
A quick look at how many I painted vs sold (and gross revenue) shows a standout year:
- **2019:** 59 painted, 41 sold, **$6,035** gross
- **2024:** 33 painted, 30 sold, **$3,990** gross

### Which sizes sell best?
The “workhorse” size is clear:

- **8x10:** 130 made, 67 sold (**52%** sell-through), avg **$113.96**, gross **$7,635**
- **12x16:** 67 made, 18 sold (**27%**), avg **$177.78**, gross **$3,200**
- **16x20:** lower sell-through (**20%**) but higher avg price (**$333**)

### Average price per square inch
Across all sold paintings:
- **Average price density:** **$2.42 per square inch**

---
