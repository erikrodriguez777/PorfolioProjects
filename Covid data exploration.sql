Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinationsEditedcsv$
--order by 3,4

--select the data that we will be using in this project

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

-- Now we will be looking at the total cases vs the total deaths
-- This data would show the likelyhood of dying if you contract Covid per county
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
order by 1, 2

-- Now we will be looking at Total cases vs Population
-- Will show what percentage of the population per location contracted Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1, 2


--Now we will look at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentPopulationInfected desc

--Now we will show the countries with the highest death count per population


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- BROKEN DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc



--Now we will show the continents with the hightest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc



--These will be the global numbers shown
--remove the "date" text to see the total global numbers in one query otherwise it will show totals by day

Select  date, SUM(new_cases) as total_cases , Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/(SUM(New_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
group by date
order by 1, 2


--Loading in the covid vaccinations table and joining it with the covid deaths table location and date

Select*
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinationsEditedcsv$ vac
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at the total population vs new vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinatedrolling
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinationsEditedcsv$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, Vaccinatedrolling)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinatedrolling
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinationsEditedcsv$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Vaccinatedrolling/population)*100
from PopvsVac



--TEMP TABLE

drop table if exists #populationvaccinatedpercentage
create table #populationvaccinatedpercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
Vaccinatedrolling numeric
)

insert into #populationvaccinatedpercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinatedrolling
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinationsEditedcsv$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (Vaccinatedrolling/population)*100
from #populationvaccinatedpercentage


--creating view to store data for later visualizations 

create view populationvaccinatedpercentage as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinatedrolling
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinationsEditedcsv$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--checking that the view can be ran as a query 

select *
from populationvaccinatedpercentage