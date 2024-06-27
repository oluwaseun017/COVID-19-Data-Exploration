# COVID-19-Data-Exploration

![Coronavirus_H picx](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/095bd45a-8ddc-475c-b470-260641b240de)



## Introduction

This repository contains the SQL queries and analysis performed on COVID-19 data using Microsoft SQL Server. The goal is to explore various aspects of the COVID-19 pandemic, including infection rates, death rates, and vaccination progress across different countries and continents to uncover insights and trends from the pandemic data.

## Problem Statement

The COVID-19 pandemic has deeply impacted countries around the globe, bringing about serious health and socio-economic challenges. It's essential to understand how the virus spreads, its mortality rate, and the progress of vaccination efforts to inform public health planning and response. In this project, we will analyze COVID-19 data to:

- Assess infection and death rates in various regions.
- Compare the mortality rates among those infected.
- Evaluate vaccination efforts and their effects on the population.


## Data Source 

This project utilizes data from [Our World in Data](https://ourworldindata.org/covid-deaths), covering the period from January 3, 2020, to September 13, 2023. The analysis is performed using Microsoft SQL Server, leveraging various SQL queries to extract meaningful information from the dataset.


## Data Exploration and Analysis

### Total Cases vs. Total Deaths

We explored the relationship between the total number of COVID-19 cases and the total number of deaths to gain insights into the virus's mortality rate. By doing this, we calculated the death percentage for each country.

```sql
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/ CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1, 2
```

![case dealth](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/bf3e5ef5-3d9c-43b0-a6de-e9e00753c05b)


### Total Cases vs. Population

We looked at the percentage of the population infected with COVID-19 in various countries. This analysis helps us understand how widely the virus spread in relation to the size of each country's population.

```sql
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
ORDER BY 1, 2
```

![casepopu](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/5715636a-c524-4d4c-b91f-6a261147d54e)


### Countries with Highest Infection Rates

In this analysis, we identified the countries with the highest infection rates relative to their populations. This highlights the regions where COVID-19 spread most rapidly.

```sql
SELECT location, population, MAX(CAST(total_cases AS BIGINT)) AS HighestInfectionCount, MAX((CAST(total_cases AS BIGINT)/population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
```

![highestinfection](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/c868b277-0e63-49e7-b290-87fdd86e4a04)


### Countries with Highest Death Counts

We examined which countries had the highest total death counts to understand where the virus had the most significant impact in terms of fatalities.

```SQL
SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--  the United States has reported a total of 1,127,152 deaths due to COVID-19, followed by Brazil with 704,659 deaths, and India with 532,027 deaths.
```

![highestdeathcount](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/a3753148-1297-46fa-8778-6f2adf2f0acc)



### Top 10 Countries with Highest Total Cases

Let's explore the top 10 countries with the highest recorded total cases.

```sql
SELECT TOP 10 location, MAX(CAST(total_cases AS BIGINT)) AS TotalCases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalCases DESC

-- The United States leads in total cases, followed by China and India.
```
![top 10](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/1186c78c-8174-4bc6-9f1a-c73a3fce1279)


### Let Break Things down by Continent

To show the continent with the highest death count per population, this helps identify the continent most severely affected by COVID-19 in terms of total reported deaths

```sql
SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
```

![continent](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/36b05623-2c67-41f2-9b6e-b358351e4d71)

This analysis shows that North America has the highest total death count, followed by South America and Asia. Europe, Africa, and Oceania have progressively fewer deaths. This data helps us understand which continents have been most severely affected by COVID-19 in terms of fatalities.


### Global Numbers

This analysis calculates the total number of COVID-19 cases, total deaths, and the death percentage for each continent. It provides a global perspective on the impact of the virus, helping us compare how severely it spread and its fatality rate across different regions.

```sql
SELECT continent, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
	SUM(CAST(new_deaths AS INT))/NULLIF(SUM(new_cases),0) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 1, 2
```

![continent 2](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/f1cf755b-7ba4-4981-a410-de27e79022ca)

Africa and South America have the highest death percentages at around 1.98%, Asia has the most cases but a lower death percentage at 0.54%, Europe has a 0.83% death percentage, North America has a 1.29% death percentage, and Oceania has the lowest at 0.20%.


### Total Number of Vaccinations Administered Globally

This query calculates the total number of COVID-19 vaccinations given in each country. It helps us understand global vaccination efforts and see which countries have administered the most vaccines.

```sql
SELECT location, SUM(CAST(ISNULL(total_vaccinations, 0) AS BIGINT)) AS TotalVaccinations
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalVaccinations DESC
```

![vacinn](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/cf657701-2369-4d73-a285-4dfaf20b467b)

This analysis shows that China and India have administered the highest number of vaccinations, followed by the United States and Brazil. Japan, Germany, and France also have substantial vaccination numbers, reflecting global efforts to combat COVID-19 through widespread vaccination campaigns.


### Number of New Cases and Deaths Change Over Months

This query calculates the total number of new COVID-19 cases and deaths for each month, allowing us to track how the pandemic's impact changes over time.

```sql
SELECT YEAR(date) AS Year, MONTH(date) AS Month, SUM(new_cases) AS MonthlyNewCases, SUM(new_deaths) AS MonthlyNewDeaths
FROM CovidDeaths
GROUP BY YEAR(date), MONTH(date)
ORDER BY Year, Month
```
![Untitledmmmmmm](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/581582fb-4d78-4bd0-9a83-72ed72f432f6)

This anaysis show the COVID-19 cases and deaths each month from 2020 to 2023, revealing fluctuations with peaks in 2020 and 2021, followed by substantial drops in 2022 and 2023. This suggests that vaccinations and public health efforts have likely played a role in reducing the numbers over time.


## Vaccination Data Analysis

The analysis also includes vaccination data, examining the percentage of the population vaccinated over time. This helps in understanding the progress of vaccination campaigns and their potential impact on infection and death rates.

### looking at total population VS vacination

This query combines COVID-19 population and vaccination data from the CovidDeaths and CovidVaccinations tables. It displays the continent, location, date, population, and new vaccinations. The results include entries where the continent is specified, sorted by location and date.

```sql
-- Join CovidDeaths and CovidVaccinations tables

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3
```

![join 22](https://github.com/oluwaseuntaiwo/COVID-19-Data-Exploration/assets/145341799/09f7cb35-c045-44f7-a019-7f849f5e8bf5)



### Using CTE (Common Table Expression) to calculate rolling people vaccinated/percentage

This query combines data from CovidDeaths and CovidVaccinations into a temporary table, including the continent, location, date, population, new vaccinations, and a running total of people vaccinated. It then retrieves all columns from this table and calculates the percentage of the population vaccinated up to each date.

```sql
WITH POPvsVAC (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(FLOAT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as RollingPeoplePercentage
FROM POPvsVAC
```

### Using temporary table to calculate percentage of population vaccinated

This query creates a temporary table to merge data from CovidDeaths and CovidVaccinations, tracking cumulative vaccinations by location and date. It then fetches all details from this table, including the calculated percentage of the population vaccinated up to each recorded date.

```sql
Using TEMP TABLE

Create Table #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(FLOAT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated
```


### Create view to store data for later visualization

This query creates a view to store the rolling number of people vaccinated and the percentage of the population vaccinated for each location for later visualization.

```sql
--Create view to store data for later Visualization

create view PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(FLOAT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
```

## Conclusion

The analysis provides valuable insights into the spread and impact of COVID-19 across different regions. By understanding the relationship between total cases, deaths, and population, as well as the progress of vaccination campaigns, policymakers and health organizations can better prepare for future health crises and allocate resources more effectively.






