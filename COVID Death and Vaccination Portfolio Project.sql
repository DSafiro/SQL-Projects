/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4

 select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2


-- Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs. Population
-- Shows percentage of population infected with COVID

 select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

-- Countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as percent_population_infected
from ProjectPortfolio..CovidDeaths
where continent is not null
group by location, population
order by percent_population_infected desc

-- Countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as total_death_counts
from ProjectPortfolio..CovidDeaths
where continent is not null
group by location
order by total_death_counts desc

-- Breaking things down by Continent
-- Continents with the highest death count per population

select location, MAX(cast(total_deaths as int)) as total_death_counts
from ProjectPortfolio..CovidDeaths
where continent is not null
group by location
order by total_death_counts desc

-- Global Numbers

 select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from ProjectPortfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total Population vs. Vaccinations
-- Shows percentage of population that has recieved at least one COVID vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from ProjectPortfolio..CovidDeaths as dea
join ProjectPortfolio..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform calculation on partition by in previous quary
;
with population_vs_vaccines (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from ProjectPortfolio..CovidDeaths as dea
join ProjectPortfolio..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_people_vaccinated/population)*100
from population_vs_vaccines

-- Using Temp Table to perform calculation on partition by in previous quarry

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from ProjectPortfolio..CovidDeaths as dea
join ProjectPortfolio..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated

go


-- Creating view to store data for visualization
	
alter view percent_population_vaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from ProjectPortfolio..CovidDeaths as dea
join ProjectPortfolio..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


