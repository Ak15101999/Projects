select *from CovidDeaths
where continent is not null
select *from CovidVaccinations
order by 3,4

--select the data that we are going to br using
select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage 
from CovidDeaths where location like'%states%' and where continent is not null
order by 1,2

--total cases vs population
--shows the percentage of populstion got covid
select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths 
--where location like'%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths group by location, population order by PercentagePopulationInfected desc

--showing the countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathsCount
from CovidDeaths where continent is not null
group by location  order by totaldeathsCount desc

--let's break things down by continent
select continent,max(cast(total_deaths as int)) as totaldeathsCount
from CovidDeaths where continent is not null
group by continent  order by totaldeathsCount desc

--showing continent with the highest death count per population
select continent,max(cast(total_deaths as int)) as totaldeathsCount
from CovidDeaths where continent is not null
group by continent  order by totaldeathsCount desc

--global numbers
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage from CovidDeaths
where continent is not null group by date order by 1,2

--looking AT total populayion vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


