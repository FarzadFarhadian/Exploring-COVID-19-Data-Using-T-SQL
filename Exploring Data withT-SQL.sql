select * from [dbo].[CovidDeath]
order by 3,4

--select * from [dbo].[CovidVaccination]
--order by 3,4

--Select Data that we are going to be useing

select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[CovidDeath]
order by 1,2


--looking at Total Cases vs Total Death

--change data type column for divide it

alter table [dbo].[CovidDeath] alter column [total_cases] int
alter table [dbo].[CovidDeath] alter column [total_deaths] int
 
 --shows likelihood of dying of you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeath]
where location like '%states%'
order by 1,2

--looking at Total Cases VS Population

--shows what Percentage of Population got Covid

select location,date,total_cases,population,(total_cases/population)*100 as infectedPercentage
from [dbo].[CovidDeath]
where location like '%iran%'
order by 1,2

--looking at countries whit Highest Infection Rate compared to Population

select location,max(total_cases) as HighestInfectionCount,population,max(total_cases/population)*100 as infectedPercentage
from [dbo].[CovidDeath]
Group by Location,population
order by infectedPercentage desc

--Showing Countries With Highest Death Count per Population
update [dbo].[CovidDeath] set  [continent]=null where [continent]=''

select location,max(Total_deaths) as TotalDeathCount
from [dbo].[CovidDeath]
where continent is not null
Group by Location
order by TotalDeathCount desc

--Lets Break Thing Down by continent

select continent,max(Total_deaths) as TotalDeathCount
from [dbo].[CovidDeath]
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Number

select sum(new_cases)as total_cases,sum(new_deaths )as total_deaths ,sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from[dbo].[CovidDeath]
where continent  is not null
--group by date
order by 1,2

--looking at Total Population VS Vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3

 
 --USE CTE

with PopvsVac (continent,location,date,Population,NEW_VACCINATION,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population) from PopvsVac


--TEMP TABLE

CREATe Table #percentpopulationVaccinatedd
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population nvarchar(255),
new_vaccination numeric,
RollingPeopleVaccination  numeric
)
insert into #percentpopulationVaccinatedd
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingpeopleVaccination
from [dbo].[CovidDeath] dea
join [dbo].[CovidVaccination] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
select *,(RollingpeopleVaccination/population)*100 from #percentpopulationVaccinatedd

