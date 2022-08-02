Select*
From [PortfolioProject ]..CovidDeaths
Where continent is not null
order by 3,4

Select*
From [PortfolioProject ]..CovidVaccinations
order by 3,4

--Select Data that I am going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject]..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioProject]..CovidDeaths
Where location like '%South%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of the Population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From [PortfolioProject]..CovidDeaths
Where location like '%States%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
From [PortfolioProject]..CovidDeaths
--Where location like '%States%'
Group by Location, Population
order by PercentPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT--

--Showing continents with the highest death count per population


Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From [PortfolioProject]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS grouped by date
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From [PortfolioProject]..CovidDeaths
Where continent is not null
Group By date
order by 1,2

--Global Numbers TOTAL
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From [PortfolioProject]..CovidDeaths
Where continent is not null
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location  Order by dea.Date) as RollingPeopleVaccinated
--,(RollingPeoplVaccinated/population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


-- TEMP TABLE
 
 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric, 
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location  Order by dea.Date) as RollingPeopleVaccinated
--,(RollingPeoplVaccinated/population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location  Order by dea.Date) as RollingPeopleVaccinated
--,(RollingPeoplVaccinated/population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated