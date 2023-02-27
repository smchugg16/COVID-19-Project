---COVID 19 Project Data Exploration---
/* 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



--- Previewing both Datasets---

Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4 

Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null
order by 3,4 



-- Selecting Data for Use -- 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
ORDER BY 1,2 

-- Comparing Total Cases vs. Total Deaths -- 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
ORDER BY 1,2 

/* Looking at the United States to calculate likelihood of death after contracting Covid*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2 

-- Comparing Total Cases vs. Population (United States) to show percentage of population infected with Covid -- 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2 

/* Calculating percentage of population that died due to Covid in the United States by date */
SELECT location, date, population, total_deaths, (total_deaths/population)*100 AS PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population -- 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 

-- Countries with Highest Death Count per Population --

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC

/* Breaking Highest Death Count down by Continent */

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Highest Death Count per Population within each Continent --

SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS --

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null 
GROUP BY date
ORDER BY 1,2


-- Total Population vs. Vaccinations --

/*Using CONVERT*/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.Date) AS RollingPeopleVaxed
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

/*Calculating percentage of population vaccinated
Using CTE to perform Calculation on Partition By in previous query*/

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaxed)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.Date) AS RollingPeopleVaxed
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT *, (RollingPeopleVaxed/Population)*100 
FROM PopvsVac

/* Using a Temp Table to perform the Calculation on Partition By in Total Pop'n vs. Vax query*/

DROP TABLE IF exists #PercentPopulationVaxed
CREATE TABLE #PercentPopulationVaxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaxed numeric
)

INSERT into #PercentPopulationVaxed
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
/* , (RollingPeopleVaxed/Population)*100 */
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
/*where dea.continent is not null
order by 2,3*/

SELECT *, (RollingPeopleVaxed/Population)*100
FROM #PercentPopulationVaxed


-- Creating Views to store data for later visualizations -- 
DROP VIEW IF exists PercentPopulationVaxed

CREATE VIEW PercentPopulationVaxed AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaxed
--, (RollingPeopleVaxed/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 

---
DROP VIEW IF exists DeathPercentages

CREATE VIEW DeathPercentages AS 
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null 
GROUP BY date

---
DROP VIEW IF exists TotalDeathCounts

CREATE VIEW TotalDeathCounts AS
SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null 
GROUP BY continent
