SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we will be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases compared to Total Deaths
-- Probability of dying from Covid in the UK

Select Location, Date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS 'Percentage of Death'
From PortfolioProject..CovidDeaths
WHERE location LIKE '%united kingdom%'
AND continent IS NOT NULL
order by 1,2

-- Looking at Total Cases Vs Population
-- % of Population with Covid
Select Location, Date, total_cases, Population, ((total_cases/Population)*100) AS 'Percentage of Infected'
From PortfolioProject..CovidDeaths
WHERE location LIKE '%united kingdom%'
AND continent IS NOT NULL
order by 1,2

-- Countries with highest infection rate compared to Population
Select Location, Population, MAX(total_cases) AS 'Highest Infection Count', MAX((total_cases/Population)*100) AS 'Percent of Population Infected'
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
order by 'percent of population infected' desc

-- Countries with highest death count per population
Select Location, 
Population, 
MAX(cast(total_deaths AS int)) AS 'Total Death Count',
MAX((cast(total_deaths AS int)/Population)*100) AS 'Percent of Death'
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
order by 'Total Death Count' desc

-- Death Count for Each Continent's Population
Select Location,
MAX(cast(total_deaths AS int)) AS 'Total Death Count'
From PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY Location
order by 'Total Death Count' desc

-- GLOBAL NUMBERS
Select  
date, SUM(new_cases) AS 'Total Cases',
SUM(CAST(new_deaths AS INT)) AS 'Total Death Count',
SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS 'Death Percentage'
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
order by 1, 2

-- Total Population Vs Vaccinations
Select  dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS 'Rolling Vaccination per Country',
--(('Rolling Vaccination per Country')/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2, 3

-- USE CTE

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingVaccinationPerCountry)
AS 
(
Select  
dea.continent,
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationPerCountry
--(('Rolling Vaccination per Country')/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2, 3
)
SELECT *, (RollingVaccinationPerCountry/Population)*100
FROM PopVSVac

-- TEMP TABLE

Drop Table if exists #PercentVaccinatedPopulation
CREATE Table #PercentVaccinatedPopulation
(
Continent nvarchar(255),
oation nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationsPerCountry numeric
)

INSERT INTO #PercentVaccinatedPopulation
Select  
dea.continent,
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationPerCountry
--(('Rolling Vaccination per Country')/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2, 3

SELECT *, (RollingVaccinationsPerCountry/Population)*100
FROM #PercentVaccinatedPopulation

-- Creating View  to store data for later visualisations

USE PortfolioProject
GO
CREATE View PercentVaccinatedPopulation AS 
Select  
dea.continent,
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationPerCountry
--(('Rolling Vaccination per Country')/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2, 3

SELECT *
FROM PercentVaccinatedPopulation