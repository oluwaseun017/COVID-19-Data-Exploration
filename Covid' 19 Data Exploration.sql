
------COVID 19 Data Exploration


SELECT *
FROM CovidVaccinations
ORDER BY 3, 4

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Select Data that we are going to be Using

SELECT location, continent, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--We are going to Looking at the Total Case VS Total Deaths

--Shows Percentage rate of Dying if one Contract Covid in the Country


SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/ CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1, 2


--Looking at Total Cases VS Population

--Shows what Percentage of Population got covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
ORDER BY 1, 2


SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2


--Looking at Countries with Highest Infection rate Compared to Population


SELECT location, population, MAX(CAST(total_cases AS BIGINT)) AS HighestInfectionCount, max((CAST(total_cases AS BIGINT)/population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--Showing Countries with Highest Death Count per Population

--Using CAST Function to change the data type of "total_deaths" column from nvarchar to "INTEGER"

SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing the Top 10 Countries with the highest Total Cases?

SELECT TOP 10 location, MAX(CAST(total_cases AS BIGINT)) AS TotalCases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalCases DESC



--Let Break Things down by Continent

--Showing Continent with the Highest Death Count per Population


SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT continent, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
	SUM(CAST(new_deaths AS INT))/NULLIF(SUM(new_cases),0) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 1, 2


--Showing the daily trend of new cases and new deaths globally?

--USING ISNULL function replaces NULL values with 0 to ensure there are no issues during aggregation.

SELECT date, SUM(CAST(ISNULL(total_cases, 0) AS BIGINT)) AS TotalNewCases, SUM(CAST(ISNULL(total_deaths, 0) AS BIGINT)) AS TotalNewDeaths
FROM CovidDeaths
GROUP BY date
ORDER BY date


--Showing  the Total Number of Vaccinations Administered Globally

SELECT continent, SUM(CAST(ISNULL(total_vaccinations, 0) AS BIGINT)) AS TotalVaccinations
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY continent


SELECT location, SUM(CAST(ISNULL(total_vaccinations, 0) AS BIGINT)) AS TotalVaccinations
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalVaccinations DESC


--Showing the Number of New Cases and Deaths Change over Months

--Using YEAR(date) and MONTH(date) functions to extract the year and month from the date column

SELECT YEAR(date) AS Year, MONTH(date) AS Month, SUM(new_cases) AS MonthlyNewCases, SUM(new_deaths) AS MonthlyNewDeaths
FROM CovidDeaths
GROUP BY YEAR(date), MONTH(date)
ORDER BY Year, Month



--looking at total population VS vacination

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(FLOAT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--Using CTE

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
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM POPvsVAC


--Using TEMP TABLE

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







































