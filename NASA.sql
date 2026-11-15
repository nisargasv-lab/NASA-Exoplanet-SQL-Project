CREATE DATABASE NASA_db

USE NASA_db

CREATE TABLE discovery_methods_new (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    discovery_method VARCHAR(100) UNIQUE
);

INSERT INTO discovery_methods_new (discovery_method)
SELECT DISTINCT discoverymethod
FROM nasa_import_check
WHERE discoverymethod IS NOT NULL;

CREATE TABLE exoplanets_new (
    pl_name VARCHAR(255) PRIMARY KEY,
    hostname VARCHAR(255),
    disc_year INT,
    pl_orbper DOUBLE,
    pl_rade DOUBLE,
    pl_bmasse DOUBLE,
    st_teff INT,
    st_mass DOUBLE,
    method_id INT,
    FOREIGN KEY (method_id)
        REFERENCES discovery_methods_new(method_id)
);

INSERT INTO exoplanets_new
SELECT
    n.pl_name,
    n.hostname,
    n.disc_year,
    n.pl_orbper,
    n.pl_rade,
    n.pl_bmasse,
    n.st_teff,
    n.st_mass,
    d.method_id
FROM nasa_import_check n
LEFT JOIN discovery_methods_new d
    ON n.discoverymethod = d.discovery_method;
    
SELECT COUNT(*) FROM exoplanets_new;

SELECT COUNT(*) FROM discovery_methods_new;

SELECT
    COUNT(*) AS total_planets,
    COUNT(method_id) AS linked_planets,
    COUNT(*) - COUNT(method_id) AS unlinked_planets
FROM exoplanets_new;

/*Q1. Which exoplanet discovery methods have contributed the most to the total number of confirmed exoplanets recorded in the NASA Exoplanet Archive?*/

SELECT discoverymethod,
	   count(*) AS totalplanets
FROM nasa_import_check
GROUP BY discoverymethod
ORDER BY totalplanets DESC

/*Q2. Which year had the highest number of exoplanet discoveries?*/

SELECT 
    disc_year,
    COUNT(pl_name) AS numplanets
FROM exoplanets_new
GROUP BY disc_year
ORDER BY numplanets DESC
LIMIT 1;

/*Q3. Which host stars have the highest number of exoplanets?*/

SELECT
    hostname,
    COUNT(pl_name) AS totalplanets
FROM exoplanets_new
GROUP BY hostname
ORDER BY totalplanets DESC
LIMIT 10;

/*Q4. What are the 10 largest exoplanets based on planetary radius?*/

SELECT
    pl_name,
    pl_rade
FROM exoplanets_new
ORDER BY pl_rade DESC
LIMIT 10;

/*Q5.Identify the largest exoplanet in the dataset and record its radius.*/

SELECT
    pl_name,
    pl_bmasse
FROM exoplanets_new
ORDER BY pl_bmasse DESC
LIMIT 10;

/*Q6.Which exoplanet discovery methods have an average planetary radius greater than the overall average radius of all exoplanets?*/

SELECT
    dm.discovery_method,
    AVG(ex.pl_rade) AS avg_radius
FROM exoplanets_new ex
INNER JOIN discovery_methods_new dm
    ON ex.method_id = dm.method_id
GROUP BY dm.discovery_method
HAVING AVG(ex.pl_rade) > (
    SELECT AVG(pl_rade)
    FROM exoplanets_new
); 

/*Q7.Find host stars that:
1. Have more than 3 exoplanets discovered using the Transit method.
2. Have an average planetary radius greater than 2 Earth radii.*/

SELECT
    ex.hostname,
    COUNT(ex.pl_name) AS total_planets,
    AVG(ex.pl_rade) AS avgrad
FROM exoplanets_new ex
INNER JOIN discovery_methods_new dm
    ON ex.method_id = dm.method_id
WHERE dm.discovery_method = 'Transit'
GROUP BY hostname
HAVING COUNT(ex.pl_name) > 3
   AND AVG(ex.pl_rade) > 2
ORDER BY total_planets DESC;

/*Q8.Find discovery methods that:
1. Have recorded more than 100 exoplanet discoveries after 2010.
2. Calculate the average planetary mass for each qualifying method.
3. Rank the methods by average planetary mass, highest average first.*/

SELECT
    dm.discovery_method,
    COUNT(ex.pl_name) AS total_planets,
    AVG(ex.pl_bmasse) AS avg_mass,
    DENSE_RANK() OVER (
        ORDER BY AVG(ex.pl_bmasse) DESC
    ) AS method_rank
FROM exoplanets_new ex
INNER JOIN discovery_methods_new dm
    ON ex.method_id = dm.method_id
WHERE ex.disc_year > 2010
GROUP BY dm.discovery_method
HAVING COUNT(ex.pl_name) > 100
ORDER BY avg_mass DESC;

/*Q9.Find all exoplanets whose mass is greater than the average mass of planets discovered using the same discovery method.

For example:
- If a planet was discovered using Transit, compare its mass against the average mass of all Transit-discovered planets.
- If discovered using Radial Velocity, compare it against the Radial Velocity average.
Display:
1. Planet name
2. Host star
3. Discovery method
4. Planet mass
5. Average mass for that discovery method*/


WITH method_average AS (
    SELECT
        method_id,
        AVG(pl_bmasse) AS avg_mass
    FROM exoplanets_new
    GROUP BY method_id
)

SELECT
    ex.pl_name,
    dm.discovery_method,
    ex.hostname,
    ex.pl_bmasse AS planet_mass,
    ma.avg_mass
FROM exoplanets_new ex
INNER JOIN discovery_methods_new dm
    ON ex.method_id = dm.method_id
INNER JOIN method_average ma
    ON ex.method_id = ma.method_id
WHERE ex.pl_bmasse > ma.avg_mass
ORDER BY planet_mass DESC;  


/*Q10.Find the top 3 host stars with the highest number of exoplanets discovered under each discovery method.

For example:
- Top 3 host stars for Transit
- Top 3 host stars for Radial Velocity
- Top 3 host stars for Imaging
- And so on.*/

WITH host_counts AS (
    SELECT
        dm.discovery_method,
        ex.hostname,
        COUNT(ex.pl_name) AS total_planets
    FROM exoplanets_new ex
    INNER JOIN discovery_methods_new dm
        ON ex.method_id = dm.method_id
    GROUP BY dm.discovery_method, ex.hostname
),
ranked_hosts AS (
    SELECT
        discovery_method,
        hostname,
        total_planets,
        DENSE_RANK() OVER (
            PARTITION BY discovery_method
            ORDER BY total_planets DESC
        ) AS planet_rank
    FROM host_counts
)
SELECT *
FROM ranked_hosts
WHERE planet_rank <= 3
ORDER BY discovery_method, planet_rank;
