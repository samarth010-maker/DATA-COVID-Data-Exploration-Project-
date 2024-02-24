select *
from PortfoloiProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfoloiProject..CovidVaccination
--order by 3,4

--select data what we are going to use

select location, date, total_cases,new_cases,total_deaths,population
from PortfoloiProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from PortfoloiProject..CovidDeaths
where location like '%India%'
order by 1,2


--looking at total_cases vs population
-- shows what percentage of people got covid


select location, date,population, total_cases,(total_deaths/population)*100 as Percentagepopulationinfected
from PortfoloiProject..CovidDeaths
where location like '%India%'
order by 1,2


--looking at countries with highest infection rate compared to population
select location,population, MAX(total_cases) as HighestInfectionCount ,MAX((total_deaths/population))*100 as Percentagepopulationinfected
from PortfoloiProject..CovidDeaths
--where location like '%India%'
group by population,location
order by Percentagepopulationinfected desc


--showing countries with highest death counts per population
select location,MAX (cast(total_deaths as int)) as totaldeathcount
from PortfoloiProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by totaldeathcount desc

--lets break things by continent
select location,MAX (cast(total_deaths as int)) as totaldeathcount
from PortfoloiProject..CovidDeaths
--where location like '%India%'
where continent is null
group by location
order by totaldeathcount desc


--global numbers
select  date, sum(new_cases) as totoalcases , SUM(cast(new_deaths as int)) as totaldeaths ,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfoloiProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2

--global sum numbers
select   sum(new_cases) as totoalcases , SUM(cast(new_deaths as int)) as totaldeaths ,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfoloiProject..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1,2

--joining both the tables by date and location because they have these two in common

select *
from PortfoloiProject..CovidDeaths dav
join PortfoloiProject..CovidVaccination vac
on dav.location=vac.location
and dav.date=vac.date

-- looking on total population vs vaccinaton


select dav.continent ,dav.location, dav.date , dav.population , vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dav.location order by dav.location ,dav.date) as rollingpeoplevaccinated
from PortfoloiProject..CovidDeaths dav
join PortfoloiProject..CovidVaccination vac
on dav.location=vac.location
and dav.date=vac.date
where dav.continent is not null
order by 1,2,3

--use cte
with popvsvac(continent, location ,date , population, new_vaccination ,rollingpeoplevaccinated)
as
(

select dav.continent ,dav.location, dav.date , dav.population , vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dav.location order by dav.location ,dav.date) as rollingpeoplevaccinated
from PortfoloiProject..CovidDeaths dav
join PortfoloiProject..CovidVaccination vac
on dav.location=vac.location
and dav.date=vac.date
where dav.continent is not null
--order by 1,2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--TEMP table
drop table if exists #percentPopulationvaccinated
Create Table #percentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date  datetime,
Population numeric,
new_vaccination numeric,
rollingpeoplevaccinated  numeric
)


Insert into #percentPopulationvaccinated
select dav.continent ,dav.location, dav.date , dav.population , vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dav.location order by dav.location ,dav.date) as rollingpeoplevaccinated
from PortfoloiProject..CovidDeaths dav
join PortfoloiProject..CovidVaccination vac
on dav.location=vac.location
and dav.date=vac.date
where dav.continent is not null
--order by 1,2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentPopulationvaccinated

--creating view for storing data visualization
create view percentPopulationvaccinated as
select dav.continent ,dav.location, dav.date , dav.population , vac.new_vaccinations
, SUM( cast(vac.new_vaccinations as int)) OVER (partition by dav.location order by dav.location ,dav.date) as rollingpeoplevaccinated
from PortfoloiProject..CovidDeaths dav
join PortfoloiProject..CovidVaccination vac
on dav.location=vac.location
and dav.date=vac.date
where dav.continent is not null
--order by 1,2,3