select *
from coviddeaths;
select *
from covidvaccination;
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From coviddeaths
Where continent <> ''
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent <> ''
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where location = 'Canada'
and continent <> '' 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
Where location = 'Canada'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
-- unsigned and signed are used in place of INT
Select Location, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount 
From CovidDeaths
Where continent <> ''
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From CovidDeaths
Where continent <> ''
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
where continent <> '' 
Group By date
order by 1,2 



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create temporary Table PercentPopulationVaccinated
(
continent varchar(55),
location varchar(55),
Date datetime,
Population numeric
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO PercentPopulationVaccinated
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as signed )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date);

-- Creating View to store data for later visualizations
DROP view if exists ViewPercentPopulationVaccinated;
Create View ViewPercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '';


