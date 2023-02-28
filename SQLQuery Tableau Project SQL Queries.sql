---SQL Queries for Tableau Project---



--- 1. ---

/* United States percentage of fatal COVID cases by date */

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
GROUP BY date

/* Percentage of fatal COVID cases Worldwide */

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
ORDER BY 1,2,3


--- 2. ---

/* United States count of fatal COVID cases */

SELECT location, SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc

/* Count of fatal COVID cases by Continent */

SELECT location, SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent IS null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


--- 3. ---

/* United States' percentage of population infected */

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
GROUP BY location, population

/* Countries sorted by the percentage of population infected */ 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--- 4. ---

/* Percent of United States' population infected by day */

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
GROUP BY location, population, date

/* Highest percentage of population infected internationally */ 

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc


--- 5. ---

/* Rolling count of percentage of population vaccinated by Country by Date */ 

WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac

