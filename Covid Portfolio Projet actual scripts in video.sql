Select *
From PortfolioProjet1..CovidDeaths
Where continent is not null
order by 3,4



--Select *
--From PortfolioProjet1..CovidVaccinations
--order by 3,4

-- Select Data That We Are Going to be using

Select location, date, total_cases, total_deaths, population
From PortfolioProjet1..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Showing 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProjet1..CovidDeaths
Where location like '%Morocco%' 
and continent is not null

order by 1,2

--Looking at Total Cases Vs Population
--Shows What percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProjet1..CovidDeaths
Where location like '%Morocco%' 
and continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProjet1..CovidDeaths
--Where location like '%Morocco%' 
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


--Showing Countries With Highest Death Count Per Population

Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProjet1..CovidDeaths
--Where location like '%Morocco%' 
Where continent is not null
Group by Location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProjet1..CovidDeaths
--Where location like '%Morocco%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select date, Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
 (New_Cases)*100 as DeathPercentage
From PortfolioProjet1..CovidDeaths
--Where location like '%Morocco%' 
where continent is not null
Group by date
order by 1,2



--Looking at Total Population Vs Vaccinations
-- USE CTE


;with PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated



from PortfolioProjet1..CovidDeaths dea
join PortfolioProjet1..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--	order by 2,3 
)
Select* , (RollingPeopleVaccinated/Population)*100
From PopVsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated



from PortfolioProjet1..CovidDeaths dea
join PortfolioProjet1..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--	order by 2,3 

Select* , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
USE PortfolioProjet1

Drop View  if exists PercentPopulationVaccinated;
go
Create View  PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated



from PortfolioProjet1..CovidDeaths dea
join PortfolioProjet1..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 



Select *
From PercentPopulationVaccinated