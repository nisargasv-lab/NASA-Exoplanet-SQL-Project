# Exploring NASA Exoplanet Discoveries

**A relational SQL analysis of exoplanet discovery methods, host stars, discovery years, and planetary characteristics.**

This project uses **MySQL 8.0.46** to structure and analyse an imported NASA Exoplanet Archive dataset. It demonstrates a complete SQL workflow: loading data into a staging table, normalising selected fields into relational tables, validating relationships, and answering analytical questions with SQL.

## Project objective

Explore the recorded exoplanet discoveries and identify patterns across:

- Discovery methods
- Discovery years
- Host stars
- Planetary orbital periods, radii, and masses
- Host-star temperature and mass

The analysis is **descriptive**. It explores patterns in the records and does not establish that a discovery method caused a particular type of planet to be detected.

## Dataset

The project presentation documents **6,451 imported records** and nine selected source fields.

| Column | Description |
|---|---|
| `pl_name` | Planet name |
| `hostname` | Host star |
| `discoverymethod` | Discovery technique |
| `disc_year` | Discovery year |
| `pl_orbper` | Orbital period |
| `pl_rade` | Planet radius, in Earth radii |
| `pl_bmasse` | Planet mass, in Earth masses |
| `st_teff` | Host star's effective temperature |
| `st_mass` | Host star's mass |

**Data source:** NASA Exoplanet Archive — https://exoplanetarchive.ipac.caltech.edu/

The original CSV export is not included in this repository package. To reproduce the analysis, download the relevant planetary-systems dataset from the archive and import the nine fields above into a MySQL staging table named `nasa_import_check`.

## Database design

The SQL script creates a database named `NASA_db` and builds two related tables:

### `discovery_methods_new`

A lookup table containing one row per distinct discovery method.

- `method_id` — primary key
- `discovery_method` — unique discovery-method name

### `exoplanets_new`

A planet-level table containing the selected planet and host-star attributes.

- `pl_name` — primary key
- `hostname`
- `disc_year`
- `pl_orbper`
- `pl_rade`
- `pl_bmasse`
- `st_teff`
- `st_mass`
- `method_id` — foreign key referencing `discovery_methods_new`

The relationship is one-to-many: one discovery method can be associated with many planet records. This design avoids repeating the discovery-method text in every planet row and supports consistent joins.

## Workflow

1. Import the source CSV into the staging table `nasa_import_check`.
2. Create the discovery-method lookup table.
3. Create the planet table with a foreign-key relationship.
4. Populate the lookup table with distinct discovery methods.
5. Insert planet records and map each record to its discovery-method ID.
6. Validate the imported and linked record counts.
7. Run the analytical SQL queries.

### Validation documented in the project

| Check | Result |
|---|---:|
| Imported source records | 6,451 |
| Records in normalized planet table | 6,451 |
| Records linked to a discovery method | 6,451 |
| Unlinked records | 0 |

These are the validation results recorded during the project.

## Analytical questions

The SQL script addresses the following questions:

1. Which discovery methods have the highest number of recorded exoplanets?
2. Which year has the highest number of recorded discoveries?
3. Which host stars have the most exoplanets?
4. Which are the ten largest exoplanets by planetary radius?
5. Which are the ten most massive exoplanets by planetary mass?
6. Which discovery methods have an average planetary radius above the overall average?
7. Which host stars have more than three Transit-discovered planets and an average planetary radius greater than two Earth radii?
8. Which discovery methods recorded more than 100 discoveries after 2010, and how do they rank by average planetary mass?
9. Which planets have a mass above the average mass for their discovery method?
10. Which are the top three host stars by planet count within each discovery method?

## SQL concepts demonstrated

- Database and table creation
- Primary keys and foreign keys
- Data insertion and relational table design
- `SELECT`, `WHERE`, `ORDER BY`, and `LIMIT`
- Aggregate functions: `COUNT()` and `AVG()`
- `GROUP BY` and `HAVING`
- `INNER JOIN`
- Subqueries
- Common Table Expressions (CTEs)
- Window functions: `DENSE_RANK()` and `PARTITION BY`
- Data validation through record counts and relationship checks

## Key finding documented

The project analysis identified **2016** as the year with the highest number of recorded discoveries in the imported dataset.

A peak in recorded discoveries does not, by itself, explain why that peak occurred. Further investigation would be needed to assess possible contributing factors.

## Repository contents

```text
NASA-Exoplanet-SQL-Project/
│
├── README.md
├── NASA.sql
├── NASA_Exoplanet_SQL_Project_Presentation.pptx
└── NASA_Exoplanet_SQL_Project.mp4
```

The SQL file contains the database design, data-loading statements, validation checks, and analytical queries. The presentation explains the project context, workflow, schema, query logic, and conclusions. The video is included as a project walkthrough.

## How to run the SQL script

1. Install MySQL Server 8.0 and MySQL Workbench.
2. Download the relevant dataset from the [NASA Exoplanet Archive](https://exoplanetarchive.ipac.caltech.edu/).
3. Import the CSV into MySQL as a staging table named `nasa_import_check`.
4. Confirm that the staging table contains the nine fields listed in the Dataset section, with compatible data types.
5. Open `NASA.sql` in MySQL Workbench.
6. Execute the database creation, table creation, insertion, and validation statements in order.
7. Run the analytical queries and inspect the result sets.

**Important:** The SQL script expects `nasa_import_check` to exist before the normalization and insertion statements are run. The source CSV and staging-table import operation are not included in the supplied SQL script.

## Limitations and reproducibility notes

- The original CSV export is not bundled here; results depend on using the corresponding source export.
- Planet mass, radius, and stellar measurements can contain `NULL` values. For example, `AVG()` ignores `NULL` values.
- The project presentation records the import and relationship checks, but not every query's result table.
- Discovery counts describe the records in the imported dataset; they should not be interpreted as a complete measure of the underlying population of exoplanets or as proof of observational bias.
- The project uses the dataset and table structure documented in the accompanying SQL script and presentation.

## Tools

- MySQL 8.0.46
- MySQL Workbench 8.0.46
- NASA Exoplanet Archive

---

**Project type:** SQL Data Analysis  
**Focus:** Astronomy data, relational database design, and analytical SQL
