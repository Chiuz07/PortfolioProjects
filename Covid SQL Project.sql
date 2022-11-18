SELECT *
FROM [Portfolio Project]..['CovidDeath$']
where continent is not null
order by 3,4


SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['CovidDeath$']
where continent is not null
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in The United States
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..['CovidDeath$']
WHERE location like '%states'
and continent is not null
order by 1, 2


-- Looking at Total Cases vs population
SELECT Location, Date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..['CovidDeath$']
WHERE location like '%states'
and continent is not null
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..['CovidDeath$']
--WHERE location like '%states'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per population
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..['CovidDeath$']
--WHERE location like '%states'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing Continent with Highest Death Count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..['CovidDeath$']
--WHERE location like '%states'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as BIGint)) as total_deaths, SUM(CAST(New_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From [Portfolio Project]..['CovidDeath$']
where continent is not null
--Group By date
order by 1, 2


--Looking at Total population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['CovidDeath$'] dea
Join [Portfolio Project]..['CovidVacination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['CovidDeath$'] dea
Join [Portfolio Project]..['CovidVacination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingpeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['CovidDeath$'] dea
Join [Portfolio Project]..['CovidVacination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated