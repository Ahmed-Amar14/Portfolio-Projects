

Select * 
from portifolio..CovidDeaths$
where continent is not null 
order by 3, 4


--Select * 
--from portifolio..CovidVaccinations$
--order by 3, 4


-- select data that we are going to be using 

select  location , date , total_cases, new_cases, total_deaths,population
from portifolio..CovidDeaths$
where continent is not null 
order by 1,2

-- looking at total cases vs total deaths 

select  location , date , total_cases, total_deaths, ( total_deaths /total_cases)*100  as DeathPercentage
from portifolio..CovidDeaths$
where continent is not null 
order by 1,2


--specify my country 

Select  location , date ,new_cases, total_cases, total_deaths, ( total_deaths /total_cases)*100  as DeathPercentage
From portifolio..CovidDeaths$
where continent is not null
and location ='Egypt'
order by 1,2

-- looking at total cases  vs population 
--percentage of population got covid

Select location , date ,population, total_cases, ( total_cases /population)*100  as PercentagePopulationInfected
From portifolio..CovidDeaths$
where continent is not null
--and location ='Egypt'
order by 1,2

 --countries with highest infection rate compared to population

Select location ,population, max (total_cases) as HighestInfectionCount, max( total_cases /population)*100  as PercentagePopulationInfected
From portifolio..CovidDeaths$
where continent is not null
--and location ='Egypt'
group by location, population
order by PercentagePopulationInfected desc

-- countries with highest death count per population

Select location ,population, max (total_deaths) as HighestDeathCount, max( total_deaths/population)*100  as PercentagePopulationDeath
From portifolio..CovidDeaths$
where continent is not null
--and location ='Egypt'
group by location, population
order by PercentagePopulationDeath desc


Select location , max (cast (total_deaths as int )) as TotalDeathCount 
From portifolio..CovidDeaths$
where continent is not null
--and location ='Egypt'
group by location
order by  TotalDeathCount desc

-- BREAK THINGS DOWN BY CONTINENT

Select continent , max (cast (total_deaths as int )) as TotalDeathCount 
From portifolio..CovidDeaths$
where continent is not null
--and location ='Egypt'
group by continent
order by  TotalDeathCount desc

Select location , max (cast (total_deaths as int )) as TotalDeathCount 
From portifolio..CovidDeaths$
where continent is null
--and location ='Egypt'
group by location
order by  TotalDeathCount desc

--global numbers 
Select sum(new_cases) as totalcases, sum(cast( new_deaths as int)) as totaldeaths, (sum(cast( new_deaths as int)) /sum(new_cases))*100  as DeathPercentage
From portifolio..CovidDeaths$
where continent is not null
--and location ='Egypt'
--group by date
order by 1,2


-- total population vs vaccinations
select dea.continent, dea.location, dea.date, population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location) 
from portifolio..CovidDeaths$ as dea
join portifolio..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--using convert 
-- total population vs vaccinations
select dea.continent, dea.location, dea.date, population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from portifolio..CovidDeaths$ as dea
join portifolio..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopvsVac (continent, location, date, population, new_vacination, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from portifolio..CovidDeaths$ as dea
join portifolio..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 
from PopvsVac 

--Temp Table
drop table if exists #PercentPopulationVacinated
create table #PercentPopulationVacinated
( continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into  #PercentPopulationVacinated
select dea.continent, dea.location, dea.date, population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from portifolio..CovidDeaths$ as dea
join portifolio..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/population)*100 
from   #PercentPopulationVacinated

--Creating view to store data for later visualization  


create view PercentPopulationVacinated as
select dea.continent, dea.location, dea.date, population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from portifolio..CovidDeaths$ as dea
join portifolio..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3