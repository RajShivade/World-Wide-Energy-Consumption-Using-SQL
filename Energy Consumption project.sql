create database ENERGYDB;
Use ENERGYDB;

-- 1. Create Country Table :

create table Country_3(
Cid varchar(10) primary key,
Country_3 varchar(100) unique
);
select * from Country_3;

-- 2.  Create Emission Table :

create table emission_3(
country varchar(100),
energy_type varchar(50),
year int,
emission int,
per_capital_emission DOUBLE ,
foreign key(country)
	references country(Country_3)
);
select * from emission_3;

-- 3. CREATE Population table 

create table population_3(
countries varchar(100),
year int,
value DOUBLE,
foreign key(countries)
references country(Country_3)
);
select * from population_3;

-- 4. Create Production Table :

create table production_3(
country varchar(100),
energy varchar(50),
year int,
production_3 int,
foreign key(country)
references country(Country_3)
);
select * from production_3;
 
 -- 5. creating GDP table :
 
 create table gdp_3(
 Country_3 varchar(100),
 year int, 
 value DOUBLE,
 foreign key(Country_3)
 references country(Country_3)
 );
 select * from gdp_3;
 
 -- 6. Creating Consumption table :
 
 create table Consum_3(
 country varchar(100),
 energy varchar(50),
 year int,
 consum_3 int,
 foreign key (country)
 references country(Country_3)
 );
 select * from Consum_3;
 
-- Questions: 
-- Question for productions :

-- Q1. Total Energy Production by Country_3:
select country, sum(production) as Total_Production
from production_3 
group by country
order by Total_Production desc;

-- Q2. Total Energy Porductions By Energy Type :
select energy, sum(production) as Total_Production
from production_3
group by energy
order by Total_Production desc;

-- Q3. Compare Energy Productions and Consumption by Country and year:
SELECT
p.country,
p.year,
p.energy,
c.consumption, -- Assuming 'consumption' is the correct column name in consum_3
p.production
FROM
production_3 p
JOIN
consum_3 c ON p.country = c.country
AND p.year = c.year
AND p.energy = c.energy
ORDER BY
p.production DESC;

-- Q4. How Does Energy production per capita vary across country:
SELECT p.countries,
ROUND(SUM(p1.production) / SUM(p.value), 4) AS production_percapita
FROM population_3 p 
JOIN production_3 p1
ON p.countries = p1.country
AND p.year = p1.year
GROUP BY p.countries
ORDER BY production_percapita DESC;

-- Question on consumptions :
-- Q5. Has energy consumption increased or decreased over the years for major economies?
SELECT major_economies.country , c.year, SUM(c.consumption) as Total_Consumption
FROM consum_3 c 
JOIN (SELECT country, SUM(value) as Total_gdp
FROM gdp_3
GROUP BY country
ORDER bY Total_gdp DESC LIMIT 5) as major_economies
ON c.country = major_economies.country
GROUP BY c.year, major_economies.country
ORDER BY c.year DESC, major_economies.country;

-- Q6. What is Total Energy Consumption Country Wise:
SELECT country, sum(consumption) as Total_Consumption
FROM consum_3
GRoup By country
ORDER BY Total_Consumption;


-- Q7. What is the energy consumption per capita for each country over the last decade?
WITH recent_years AS (
SELECT MAX(year) AS max_year FROM consum_3
),
consumption_data AS (
SELECT 
c.country, 
c.year, 
c.consumption, 
p.value AS population_3
FROM 
consum_3 c
JOIN 
population_3 p ON c.country = p.countries AND c.year = p.year
WHERE 
c.year >= (SELECT max_year - 9 FROM recent_years)  -- last 10 years
)
SELECT country,
year,
ROUND(consumption / population_3, 4) AS consumption_per_capita
FROM consumption_data
ORDER BY consumption_per_capita DESC;

-- Q8 . Which Country Have Highest energy Consumption relative to GDP:
SELECT 
c.country,
ROUND(SUM(consumption) / SUM(g.value), 4) AS relative_consumption_for_gdp
FROM  consum_3 c
JOIN  gdp_3 g
ON c.country = g.country
AND c.year = g.year
GROUP BY country
ORDER BY relative_consumption_for_gdp DESC;


-- Question Releated to Emission:
-- Q9. How has population growth affected total emissions in each country?
SELECT p.countries,
p.year,SUM(e.emission) AS total_emission,
p.value AS population
FROM  population_3 p
JOIN  emission_3 e 
ON p.countries = e.country
AND p.year = e.year
GROUP BY p.countries , p.year , p.value
ORDER BY countries , year;

-- 10.What is the total emission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = 
(SELECT MAX(year) AS recent_year
FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;


-- 11. What are the top 10 countries by population and how do their emissions compare?
SELECT p.countries,
SUM(p.value) AS total_population,
SUM(e.emission) AS total_emission
FROM population_3 p
JOIN emission_3 e 
ON p.countries = e.country
AND p.year = e.year
GROUP BY p.countries
ORDER BY total_population DESC
LIMIT 10;


-- 12.Which energy types contribute most to emissions across all countries?
SELECT 
energy_type, SUM(emission_3) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;


-- Q13. How have global emissions changed year over year?
SELECT 
year,
SUM(emission) AS total_global_emissions,
SUM(emission) - LAG(SUM(emission)) OVER (ORDER BY year) AS yoy_change
FROM emission_3
GROUP BY year
ORDER BY 
year;


-- 14. What is the emission-to-GDP ratio for each country by year?
SELECT e.country, e.year,
ROUND((SUM(e.emission) / SUM(g.value)), 4) AS emission_gdp_ratio
FROM  emission_3 e
JOIN  gdp_3 g 
ON e.country = g.country
AND e.year = g.year
GROUP BY country , year
ORDER BY country , year;

-- 15. What is the global share (%) of emissions by country?
with total_emission_percountry as(
select country, sum(emission)  as total_emission 
from emission_3 group by country)
select country,round(total_emission*100/(select sum(emission) from emission_3),5) as share 
from total_emission_percountry 
order by share desc;


-- 16.What are the top 5 countries by GDP in the most recent year?
SELECT country, value
FROM gdp_3
WHERE year = (SELECT MAX(year)
FROM gdp_3)
ORDER BY value DESC
LIMIT 5;

-- 17.What is the global average GDP, emission, and population by year?
SELECT e.year,
ROUND(AVG(g.value), 5) AS avg_gdp,
ROUND(AVG(e.emission), 5) AS avg_emission,
ROUND(AVG(p.value), 5) AS avg_population
FROM emission_3 e
JOIN gdp_3 g ON e.country = g.country
AND e.year = g.year
JOIN population_3 p ON p.countries = e.country
AND p.year = e.year
GROUP BY e.year
ORDER BY e.year;


-- Summary table from all tables;
select 
p.country,p.year,
sum(p.production) as total_production,
sum(e.emission) as total_emission,
sum(c.consumption) as total_consumption,
sum(g.value) as total_gdp,
sum(p1.value) as population 
from production_3 p join emission_3 e on p.country = e.country and p.year = e.year
join consum_3 c on p.country = c.country and p.year = c.year 
join gdp_3 g on p.country=g.country and p.year= g.year 
join population_3 p1 on p.country=p1.countries and p.year= p1.year 
group by p.country,p.year 
order by year,total_production desc LIMIT 10;

