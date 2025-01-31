SELECT * 
FROM covidDeaths
ORDER BY 1;

SELECT country, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths
ORDER BY 1;


-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country  
SELECT country, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathsPercantage
FROM covidDeaths
--WHERE country = 'Egypt'
ORDER BY 1;


-- Looking at Total Cases vs population
-- shows what percentage of population got Covid
SELECT country, date, total_cases, population, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS PercentPopulationInfected
FROM covidDeaths
--WHERE country = 'Egypt'
ORDER BY 1;


-- Looking at countries with highest infection rate compared to population
SELECT country, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)))*100 AS PercentPopulationInfected
FROM covidDeaths
GROUP BY country, population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with highest Death Count Per Population
SELECT country, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covidDeaths
WHERE continent is not NULL
GROUP BY country
ORDER BY TotalDeathCount DESC;


-- Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(CAST(new_deaths as FLOAT))/SUM(CAST(new_cases AS FLOAT)))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL



-- Looking at Total population vs vaccinations
SELECT dea.continet, dea.country, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVAccinations AS vac
ON dea.country = vac.country AND dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 2,3


-- USE CTE
with PopvsVac (Continent, Country, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continet, dea.country, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVAccinations AS vac
ON dea.country = vac.country AND dea.date = vac.date
WHERE dea.continent is not NULL 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continet, dea.country, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVAccinations AS vac
ON dea.country = vac.country AND dea.date = vac.date
WHERE dea.continent is not NULL 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continet, dea.country, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVAccinations AS vac
ON dea.country = vac.country AND dea.date = vac.date
WHERE dea.continent is not NULL 


SELECT * 
FROM PercentPopulationVaccinated

