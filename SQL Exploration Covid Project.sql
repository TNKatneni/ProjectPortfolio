/*

Covid 19 Data from Jan 8, 2020 - July 26, 2023

Utilized Joins, Temp Tables, Windows Functions, CTEs, Views, Converting Data Types

*/

select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Starting Data
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths - Demonstrates the likelihood of dying if you get covid in your country 

SELECT 
    location, 
    date, 
    total_cases,
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 
    END as DeathPercentage
FROM 
    PortfolioProject.dbo.CovidDeaths
Where location = 'United States'
ORDER BY 
    1,2

--Looking at the Total Cases vs Population - Shows the percentage of the population that got Covid 
Select location, date,Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location = 'United States'
order by 1,2


-- Highest infection rate compared to population 
Select location,Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location = 'United States'
group by location,Population 
order by PercentPopulationInfected desc



-- Looking at countries with the highest death count per population 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'United States'
where continent is not null
group by location 
order by TotalDeathCount desc



-- Showing continents with highest death count 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(CAST(new_cases AS int)) as total_cases, SUM(new_deaths) as total_deaths, 
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(new_deaths) / CAST(SUM(new_cases) AS float)) * 100
    END as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(CAST(new_cases AS int)) as total_cases, SUM(new_deaths) as total_deaths, 
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(new_deaths) / CAST(SUM(new_cases) AS float)) * 100
    END as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3



-- CTE - used to perform calculation on partition by from above query 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table - used to perform calculation on partition by in previous query 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating a View to store query for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

