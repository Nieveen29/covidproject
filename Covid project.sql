Select Location, date, total_cases, new_cases, total_deaths , population 
from coviddeaths
order by 1,2 ;

--- looking at total cases Vs total deaths 
--- shows the likeihood of dying if you contract covid in your counrty 
Select Location , date, total_cases, total_deaths , (total_deaths/total_cases) * 100 as deathpercentage
from coviddeaths 
where location like '%states%' 
order by 1,2 ;

--- looking at total cases Vs population 
--- shows what percentage of population has got COVID 

select Location, 
STR_to_date(date, '%m/%d/%y')as proper_date,
 population, total_cases , 
 ROUND((CAST(total_cases AS float) / CAST(population AS FLOAT)) * 100,10) AS Percent_Population_Infected
from coviddeaths 
-- where location like '%states%' 
order by 1,2 ;


-- looking at countries with highest infection rate compared to population
 
select Location,population, MAX(total_cases) AS Highest_Infection_Count, 
 MAX(ROUND((CAST(total_cases AS float) / CAST(population AS FLOAT)) * 100,10)) AS Percent_Population_Infected
from coviddeaths 
-- where location like '%states%' 
Group by location,population

Order by  Percent_Population_Infected desc;


-- Showing Countries with the highest death count per population 

Select Location, Max(Cast(Total_deaths as signed)) As Total_death_Count
from coviddeaths 
-- where location like '%states%' 
where continent is not null
and location Not IN ('Europe', 'North America', 'South America', 'Asia' , 'world' , 'European Union') 
Group by location
Order by  Total_death_count desc;   


-- Lets break things down by continent 


Select location, max(Cast(Total_deaths as signed)) As Total_death_Count
from coviddeaths 
-- where location like '%states%' 
where lower (location) in ('world', 'europe', 'north america', 'european union', 'south america', 'asia', 'africa', 'oceania')
Group by location
Order by  Total_death_count desc; 


With latestdeaths As (
Select 
location, 
continent, 
max(Cast(Total_deaths as signed)) As latest_total_deaths 
From coviddeaths
where continent is not null
group by location, continent 
) 
select 
continent, 
Sum(latest_total_deaths) AS total_death_count
from latestdeaths
group by continent
order by total_death_count desc; 


-- global numbers 
Select date, Sum(cast(New_cases as Signed)) as total_new_cases -- ,total_deaths , (total_deaths/total_cases) * 100 as deathpercentage
from coviddeaths 
-- where location like '%states%' 
where continent is not null
group by date
order by 1,2; 


-- Global numbers part 2
SELECT 
    STR_to_date(date, '%m/%d/%y')as proper_date,
    SUM(CAST(new_cases AS SIGNED)) AS total_new_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_new_deaths,
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(CAST(new_cases AS SIGNED))) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY proper_date
ORDER BY proper_date;


SELECT *,
       STR_TO_DATE(dea.date, '%m/%d/%y') AS dea_date,
       STR_TO_DATE(vac.date, '%m/%d/%y') AS vac_date
FROM coviddeaths AS dea
JOIN covidvaccin AS vac
  ON dea.location = vac.location
 AND STR_TO_DATE(dea.date, '%m/%d/%y') = STR_TO_DATE(vac.date, '%m/%d/%y');
 
 
 -- looking at total population vs vaccinations 
 SELECT dea.continent, dea.location , dea. date , dea.population , vac.new_vaccinations,  
 SUM(cast(vac.new_vaccinations as signed)) OVER (partition by dea.location order by dea.location ,dea.date)as rolling
FROM coviddeaths AS dea
JOIN covidvaccin AS vac
  ON dea.location = vac.location
  where dea. continent is not null
 order by 2,3 
 limit 1000; 
 
 
 SELECT *,
       STR_TO_DATE(dea.date, '%m/%d/%y') AS dea_date,
       STR_TO_DATE(vac.date, '%m/%d/%y') AS vac_date
FROM coviddeaths AS dea
JOIN covidvaccin AS vac
  ON dea.location = vac.location
 AND STR_TO_DATE(dea.date, '%m/%d/%y') = STR_TO_DATE(vac.date, '%m/%d/%y');
 
-- looking at total population vs vaccinations 

SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%y') AS proper_date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%y')) AS rollingpeoplevaccinated 
       -- (rollingpeoplevaccinated/population)
FROM coviddeaths AS dea
JOIN covidvaccin AS vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, proper_date
LIMIT 1000;








-- Using CTE to calculate rolling people vaccinated with proper date formatting
WITH PopvsVAC AS (
    SELECT 
        dea.continent,
        dea.location,
        STR_TO_DATE(dea.date, '%m/%d/%y') AS proper_date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) 
            OVER (
                PARTITION BY dea.location 
                ORDER BY STR_TO_DATE(dea.date, '%m/%d/%y')
            ) AS rollingpeoplevaccinated
    FROM coviddeaths dea
    JOIN covidvaccin vac
        ON dea.location = vac.location 
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

-- Final output filtered to 2021 only because vaccinations did not happen till 2021 
SELECT *, 
       (rollingpeoplevaccinated / population) * 100 AS vaccination_percentage
FROM PopvsVAC
WHERE YEAR(proper_date) = 2021
ORDER BY location, proper_date
LIMIT 1000;


-- temp table


-- Drop if the temp table already exists
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temp table with correct syntax
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
);



 
 
INSERT INTO PercentPopulationVaccinated (
    continent, location, date, population, new_vaccinations, rollingpeoplevaccinated
)
SELECT
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%m/%d/%y'),
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (
            PARTITION BY dea.location 
            ORDER BY STR_TO_DATE(dea.date, '%m/%d/%y')
        )
FROM coviddeaths dea
JOIN covidvaccin vac
    ON dea.location = vac.location AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL;


SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    rollingpeoplevaccinated,
    (rollingpeoplevaccinated / population) * 100 AS vaccination_percentage
FROM PercentPopulationVaccinated;

-- Creating view to store data for later Visualizations 

Create view PercentPopulationVaccinated  (
    continent, location, date, population, new_vaccinations, rollingpeoplevaccinated
)as 
SELECT
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%m/%d/%y') as date, 
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (
            PARTITION BY dea.location 
            ORDER BY STR_TO_DATE(dea.date, '%m/%d/%y')
        ) as rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covidvaccin vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- order by 2,3 

Select * 
from PercentPopulationVaccinated 





