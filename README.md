# 🦠 COVID-19 Data Exploration Project

This project analyzes global COVID-19 data using SQL to uncover insights about infection trends, death rates, and vaccination progress across countries.

## 🎯 Objective

To explore and visualize COVID-19 data for better understanding of the pandemic's global impact, using SQL queries to extract meaningful insights.

## 🛠️ Tools Used

- MySQL / SQL
- Tableau (optional for visualization)
- Excel (optional for previewing datasets)

## 📁 Dataset Overview

The dataset includes:
- Daily new cases and deaths
- Cumulative totals
- Vaccination data
- Country and population data
- Date-wise breakdowns

## 🔍 Key Analyses Performed

- Calculated total cases and deaths by country
- Analyzed death rates (deaths as % of cases)
- Tracked vaccination progress across regions
- Identified countries with the highest infection rates
- Explored infection trends over time

## 🧠 Sample SQL Queries

```sql
-- Death percentage per country
SELECT 
  location, 
  MAX(total_deaths) AS TotalDeaths, 
  MAX(total_cases) AS TotalCases, 
  ROUND(MAX(total_deaths) / MAX(total_cases) * 100, 2) AS DeathPercentage
FROM covid_data
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathPercentage DESC;

-- Vaccination progress
SELECT 
  location, 
  date, 
  people_fully_vaccinated, 
  population, 
  ROUND(people_fully_vaccinated / population * 100, 2) AS VaccinationRate
FROM covid_data
WHERE people_fully_vaccinated IS NOT NULL;




The project provided a clear understanding of:

Which countries were most affected
The correlation between population size and infection rates
How vaccinations impacted case growth
