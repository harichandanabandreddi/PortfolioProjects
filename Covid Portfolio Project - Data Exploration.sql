select * 
From PortfolioProject..CovidDeaths$
order by 3,4



-- 1
-- There are issues with location
-- Example - Asia is both continent and location in the data and few continents have NULL value. we can exclude them and extract the results

select * 
From PortfolioProject..CovidDeaths$ 
where continent is not NULL
order by 3,4


-- 2
-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not NULL
order by 1,2



-- 3
-- Looking at Total Cases vs Total Deaths - percentage of how many cases are in the country and how many deaths for the entire cases

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not NULL
order by 1,2



-- 4
-- Location - United States
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%' and continent is not NULL
order by 1,2


-- 5
-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%states%' and continent is not NULL
order by 1,2

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is not NULL
order by 1,2



-- 6
-- Looking at countries with highest infection rate compared to the population
-- Example location (afghanistan) - its total population - max for total cases - percentage of its overall total_cases

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
group by Location, population
order by 1,2

-- Order by PercentPopulationInfected to see clearer results

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
group by Location, population
order by 4 desc



-- 7
-- Showing countries with highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by Location
order by TotalDeathCount desc

-- The results are confusing. It's issue with the data type of total_deaths which is nvarchar, it must be a number. We can cast it to convert into a integer.

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by Location
order by TotalDeathCount desc



-- 8
-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by continent
order by TotalDeathCount desc


-- The results are not accurate. North America seems to take count only from United States but not other locations. Considering NULL values

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is NULL
group by location
order by TotalDeathCount desc


-- 9
-- Showing the continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by continent
order by TotalDeathCount desc


-- 10
-- GLOBAL NUMBERS - want to calculate everything across the world

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by date
order by 1,2

-- When looking for multiple things, cannot Group by by just date. We need to use aggregate functions on everything else

Select date, total_cases, SUM(MAX(total_deaths))
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by date
order by 1,2


-- 11
-- Cannot perform double aggregation on single column
-- Showing total cases, total deaths, and death percentage across the world grouping by date

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by date
order by 1,2



-- 12
-- Showing total cases, total deaths, and death percentage across the world

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not NULL
order by 1,2




-- 13
-- CovidVaccination table

select *
From PortfolioProject..CovidVaccinations$



-- 14
-- Join these two tables

select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date




-- 15
-- Looking at Total population vs vaccinations. Total amount of people got vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3





-- 16
-- Want to know the rolling count for new_vaccinations. Partition by location so that when new location is added the aggregate function starts over
-- Partitions by each location and sums the new_vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location) 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Order by location and date. When using order by in over clause it rolls up the values

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3




-- 17
-- Shows how many people in the country got vaccinated. RollingPeopleVaccinated divided by Total Population of each location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	   , (RollingPeopleVaccinated / population) * 100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Error: Cannot use the column which is just created. The solution here is to use CTE or Temp table
-- Use CTE - Number of columns mentioned in CTE and select statement should be equal and same

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3
)

select *
from PopvsVac


-- Error: Order by clause is invalid in views. It shouldn't be there in CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
)

select *, (RollingPeopleVaccinated / Population) * 100 as percentage
from PopvsVac



-- Temp Table

DROP table if exists #PercentPopulationVaccinated

create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVaccinated / Population) * 100 as percentage
from #PercentPopulationVaccinated





-- 18
-- Creating View to store data for later visulaizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Order by clause is invalid in views

DROP VIEW dbo.PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   ,SUM(CONVERT(INT, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL

select * 
FROM dbo.PercentPopulationVaccinated



