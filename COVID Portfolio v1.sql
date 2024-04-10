-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases) * 100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percent of the population has contracted Covid

SELECT Location, date, total_cases, population, (CONVERT(float, total_cases) / population * 100) AS PercentInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(CONVERT(float, total_cases)) AS HighestInfectionCount, MAX((CONVERT(float, total_cases))/ population) * 100 AS PercentInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count per population

-- **This is the correct way to do this query, come back later and redo everything using this

--SELECT location, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

-- This is the way the query was done for the tutorial

SELECT continent, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Looking at continent with highest infection rate compared to population

SELECT continent, MAX(CONVERT(float, total_cases)) AS HighestInfectionCount, MAX((CONVERT(float, total_cases))/ population) * 100 AS PercentInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentInfected DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / NULLIF(SUM(new_cases),0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / NULLIF(SUM(new_cases),0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated,

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinated / population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingvaccinated numeric)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinated / population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visulaizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


Select * FROM PercentPopulationVaccinated