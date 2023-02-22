select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations

select location ,date, total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


---Looking at Total Cases vs Total Deaths
--Shows Liklihood of Death in Country

select location ,date, total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location ='israel'
and continent is not null
order by 1,2

---Looking at Total Cases vs Population 
--Shows Precentage of Popultion Contracts Covid

select location ,date, population,total_cases,
(total_cases/population)*100 as InfectionPercent
from [Portfolio Project]..CovidDeaths
where location = 'israel'
and continent is not null
order by 1,2

-- Looking at Countries with Highst Infection Rate Relative to Population

select location , population,max (total_cases)as HighestInfection ,
max((total_cases/population))*100 as InfectionPercent
from [Portfolio Project]..CovidDeaths
group by location , population
order by InfectionPercent desc


-- Showing Countries with Highest Deathcount per Popultion

select location, max(cast (total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
--where location = 'israel'
group by location
order by TotalDeathCount desc


--CONTINENT BREAKDOWN 2 ways

--RealWorld
select location, max(cast (total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is null
--where location = 'israel'
group by location
order by TotalDeathCount desc


select continent, max(cast (total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
--where location = 'israel'
group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as GlobalTotalCases, sum(cast (new_deaths as int)) as GlobaTotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from [Portfolio Project]..CovidDeaths
--where location ='israel'
where continent is not null
--group by date
order by 1,2

----Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over( partition by dea.location order by dea.location,dea.date) as RollingVacsCount
from [Portfolio Project]..CovidDeaths as DEA
join [Portfolio Project]..CovidVaccinations as VAC
on dea.location=vaC.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingVacsCount)
as 
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over( partition by dea.location order by dea.location,dea.date) as RollingVacsCount
from [Portfolio Project]..CovidDeaths as DEA
join [Portfolio Project]..CovidVaccinations as VAC
on dea.location=vaC.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3
)
select *,RollingVacsCount/population*100 as PercenageOfPopVacs
from PopvsVac


----Temp Table

drop table if exists #PercentPopulationVacsed
create table #PercentPopulationVacsed
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVacsCount numeric,
)

insert into #PercentPopulationVacsed

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over( partition by dea.location order by dea.location,dea.date) as RollingVacsCount
from [Portfolio Project]..CovidDeaths as DEA
join [Portfolio Project]..CovidVaccinations as VAC
on dea.location=vaC.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *,RollingVacsCount/population*100 as PercenageOfPopVacsed
from #PercentPopulationVacsed

---Creating View to store data for Visulazation 

create view 
PercentPopulationVacsed as

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) 
over( partition by dea.location order by dea.location,dea.date) as RollingVacsCount
from [Portfolio Project]..CovidDeaths as DEA
join [Portfolio Project]..CovidVaccinations as VAC
on dea.location=vaC.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


