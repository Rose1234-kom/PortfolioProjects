Select *
From [Portfolio Projects].dbo.CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From [Portfolio Projects].dbo.CovidVaccinations
--order by 3,4

--Select Data that I will be using

Select location, date, total_cases,new_cases,total_deaths,population
From [Portfolio Projects].dbo.CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Projects].dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2


--Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
From [Portfolio Projects].dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Countries with highest Infection rate compared to population

Select location, population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Projects].dbo.CovidDeaths$
--Where location like '%states%'
Group by location,population
order by PercentagePopulationInfected desc



--Countries with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects].dbo.CovidDeaths$
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects].dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers with date
Select  date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as tot,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Projects].dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2

--Global Numbers without date
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as tot,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Projects].dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2

-- USE CTE

With PopvsVac (Continent, Location, Date,Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths$ dea
Join [Portfolio Projects]..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--Order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths$ dea
Join [Portfolio Projects]..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date= vac.date
--where dea.continent is not null
--Order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View  PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From [Portfolio Projects]..CovidDeaths$ dea
Join [Portfolio Projects]..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated
