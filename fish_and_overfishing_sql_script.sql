-- Create Schema
DROP SCHEMA IF EXISTS fish_and_overfishing;
CREATE SCHEMA fish_and_overfishing;
USE fish_and_overfishing;


-- Create aquaculture_farmed_fish_production Table
DROP TABLE IF EXISTS aquaculture_farmed_fish_production;
CREATE TABLE aquaculture_farmed_fish_production(
	Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(8),
    Year SMALLINT NOT NULL,
    Aquaculture_production_metric_tons INT,
    PRIMARY KEY (Entity, Year)
);
    
LOAD DATA LOCAL INFILE "MyLocalPath\\fish_and_overfishing\\aquaculture-farmed-fish-production.csv"
INTO TABLE aquaculture_farmed_fish_production
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE aquaculture_farmed_fish_production
DROP COLUMN Code;

SELECT * 
FROM aquaculture_farmed_fish_production 
ORDER BY RAND() 
LIMIT 10;


-- Create capture_fishery_production Table
DROP TABLE IF EXISTS capture_fishery_production;
CREATE TABLE capture_fishery_production(
	Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(8),
    Year SMALLINT NOT NULL,
    Capture_fisheries_production_metric_tons INT,
    PRIMARY KEY (Entity, Year)
);
    
LOAD DATA LOCAL INFILE "MyLocalPath\\fish_and_overfishing\\capture-fishery-production.csv"
INTO TABLE capture_fishery_production
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE capture_fishery_production
DROP COLUMN Code;

SELECT * 
FROM capture_fishery_production 
ORDER BY RAND() 
LIMIT 10;


-- Create fish-and-seafood-consumption-per-capita Table
DROP TABLE IF EXISTS fish_and_seafood_consumption_per_capita;
CREATE TABLE fish_and_seafood_consumption_per_capita(
	Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(8),
    Year SMALLINT NOT NULL,
    fish_and_seafood_consumption_kg_capita_year DECIMAL(5,2),
    PRIMARY KEY (Entity, Year)
);
    
LOAD DATA LOCAL INFILE "MyLocalPath\\fish_and_overfishing\\fish-and-seafood-consumption-per-capita.csv"
INTO TABLE fish_and_seafood_consumption_per_capita
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE fish_and_seafood_consumption_per_capita
DROP COLUMN Code;

SELECT * 
FROM fish_and_seafood_consumption_per_capita 
ORDER BY RAND() 
LIMIT 10;


-- Create fish_stocks_within_sustainable_levels Table
DROP TABLE IF EXISTS fish_stocks_within_sustainable_levels;
CREATE TABLE fish_stocks_within_sustainable_levels(
	Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(8),
    Year SMALLINT NOT NULL,
    Share_sustainable_fish_stocks DECIMAL(6,3),
    Share_overexploited_fish_stocks DECIMAL(6,3),
    PRIMARY KEY (Entity, Year)
);
    
LOAD DATA LOCAL INFILE "MyLocalPath\\fish_and_overfishing\\fish-stocks-within-sustainable-levels.csv"
INTO TABLE fish_stocks_within_sustainable_levels
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE fish_stocks_within_sustainable_levels
DROP COLUMN Code;

SELECT * 
FROM fish_stocks_within_sustainable_levels 
ORDER BY RAND() 
LIMIT 10;


-- Create global_fishery_catch_by_sector Table
DROP TABLE IF EXISTS global_fishery_catch_by_sector;
CREATE TABLE global_fishery_catch_by_sector(
	Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(8),
    Year SMALLINT NOT NULL,
    Artisanal INT,
    Discards INT,
    Industrial INT,
    Recreational INT,
    Subsistence INT,
    PRIMARY KEY (Entity, Year)
);
    
LOAD DATA LOCAL INFILE "MyLocalPath\\fish_and_overfishing\\global-fishery-catch-by-sector.csv"
INTO TABLE global_fishery_catch_by_sector
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE global_fishery_catch_by_sector
DROP COLUMN Code;

SELECT * 
FROM global_fishery_catch_by_sector 
ORDER BY RAND() 
LIMIT 10;


-- Create seafood_and_fish_production_thousand_tonnes Table
DROP TABLE IF EXISTS seafood_and_fish_production_thousand_tonnes;
CREATE TABLE seafood_and_fish_production_thousand_tonnes(
	Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(8),
    Year SMALLINT NOT NULL,
    Pelagic_fish_2763 INT,
    Crustaceans_2765 INT,
    Cephalopods_2766 INT,
    Demersal_fish_2762 INT,
    Freshwater_fish_2761 INT,
    Molluscs_other_2767 INT,
    Marine_fish_other_2764 INT,
    PRIMARY KEY (Entity, Year)
);
    
LOAD DATA LOCAL INFILE "MyLocalPath\\fish_and_overfishing\\seafood-and-fish-production-thousand-tonnes.csv"
INTO TABLE seafood_and_fish_production_thousand_tonnes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE seafood_and_fish_production_thousand_tonnes
DROP COLUMN Code;

SELECT * 
FROM seafood_and_fish_production_thousand_tonnes
ORDER BY RAND() 
LIMIT 10;


-- Create fact Table
DROP TABLE IF EXISTS dim_entity_year;
CREATE TABLE dim_entity_year(
    entity VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    UNIQUE KEY (entity, year)
);

INSERT INTO dim_entity_year (entity, year)
SELECT Entity, Year FROM aquaculture_farmed_fish_production
UNION
SELECT Entity, Year FROM capture_fishery_production
UNION
SELECT Entity, Year FROM fish_and_seafood_consumption_per_capita
UNION
SELECT Entity, Year FROM fish_stocks_within_sustainable_levels
UNION
SELECT Entity, Year FROM global_fishery_catch_by_sector
UNION
SELECT Entity, Year FROM seafood_and_fish_production_thousand_tonnes;

ALTER TABLE dim_entity_year
ADD COLUMN entity_year_id INT AUTO_INCREMENT PRIMARY KEY;


-- Add a foreign key to aquaculture_farmed_fish_production Table
ALTER TABLE aquaculture_farmed_fish_production ADD COLUMN entity_year_id INT;
UPDATE aquaculture_farmed_fish_production affp
JOIN dim_entity_year dey ON affp.Entity = dey.entity AND affp.Year = dey.year
SET affp.entity_year_id = dey.entity_year_id;
ALTER TABLE aquaculture_farmed_fish_production DROP COLUMN Entity, DROP COLUMN Year;
ALTER TABLE aquaculture_farmed_fish_production
ADD CONSTRAINT affp_entity_year
FOREIGN KEY (entity_year_id) REFERENCES dim_entity_year(entity_year_id);


SET SQL_SAFE_UPDATES = 0;
-- Add a foreign key to capture_fishery_production Table
ALTER TABLE capture_fishery_production ADD COLUMN entity_year_id INT;
UPDATE capture_fishery_production cfp
JOIN dim_entity_year dey ON cfp.Entity = dey.entity AND cfp.Year = dey.year
SET cfp.entity_year_id = dey.entity_year_id;
ALTER TABLE capture_fishery_production DROP COLUMN Entity, DROP COLUMN Year;
ALTER TABLE capture_fishery_production
ADD CONSTRAINT cfp_entity_year
FOREIGN KEY (entity_year_id) REFERENCES dim_entity_year(entity_year_id);


-- Add a foreign key to fish_stocks_within_sustainable_levels Table
ALTER TABLE fish_and_seafood_consumption_per_capita ADD COLUMN entity_year_id INT;
UPDATE fish_and_seafood_consumption_per_capita fascpc
JOIN dim_entity_year dey ON fascpc.Entity = dey.entity AND fascpc.Year = dey.year
SET fascpc.entity_year_id = dey.entity_year_id;
ALTER TABLE fish_and_seafood_consumption_per_capita DROP COLUMN Entity, DROP COLUMN Year;
ALTER TABLE fish_and_seafood_consumption_per_capita
ADD CONSTRAINT fascpc_entity_year
FOREIGN KEY (entity_year_id) REFERENCES dim_entity_year(entity_year_id);


-- Add a foreign key to fish_stocks_within_sustainable_levels Table
ALTER TABLE fish_stocks_within_sustainable_levels ADD COLUMN entity_year_id INT;
UPDATE fish_stocks_within_sustainable_levels fswsl
JOIN dim_entity_year dey ON fswsl.Entity = dey.entity AND fswsl.Year = dey.year
SET fswsl.entity_year_id = dey.entity_year_id;
ALTER TABLE fish_stocks_within_sustainable_levels DROP COLUMN Entity, DROP COLUMN Year;
ALTER TABLE fish_stocks_within_sustainable_levels
ADD CONSTRAINT fswsl_entity_year
FOREIGN KEY (entity_year_id) REFERENCES dim_entity_year(entity_year_id);


-- Add a foreign key to global_fishery_catch_by_sector Table
ALTER TABLE global_fishery_catch_by_sector ADD COLUMN entity_year_id INT;
UPDATE global_fishery_catch_by_sector gfcbs
JOIN dim_entity_year dey ON gfcbs.Entity = dey.entity AND gfcbs.Year = dey.year
SET gfcbs.entity_year_id = dey.entity_year_id;
ALTER TABLE global_fishery_catch_by_sector DROP COLUMN Entity, DROP COLUMN Year;
ALTER TABLE global_fishery_catch_by_sector
ADD CONSTRAINT gfcbs_entity_year
FOREIGN KEY (entity_year_id) REFERENCES dim_entity_year(entity_year_id);


-- Add a foreign key to seafood_and_fish_production_thousand_tonnes Table
ALTER TABLE seafood_and_fish_production_thousand_tonnes ADD COLUMN entity_year_id INT;
UPDATE seafood_and_fish_production_thousand_tonnes safptt
JOIN dim_entity_year dey ON safptt.Entity = dey.entity AND safptt.Year = dey.year
SET safptt.entity_year_id = dey.entity_year_id;
ALTER TABLE seafood_and_fish_production_thousand_tonnes DROP COLUMN Entity, DROP COLUMN Year;
ALTER TABLE seafood_and_fish_production_thousand_tonnes
ADD CONSTRAINT safptt_entity_year
FOREIGN KEY (entity_year_id) REFERENCES dim_entity_year(entity_year_id);

SET SQL_SAFE_UPDATES = 1;


SELECT * FROM dim_entity_year ORDER BY RAND() LIMIT 10;

SELECT * FROM fish_stocks_within_sustainable_levels ORDER BY RAND() LIMIT 10;