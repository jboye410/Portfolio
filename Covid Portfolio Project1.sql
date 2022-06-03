select * from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from CovidPortfolioProject..CovidVaccinations
--order by 3,4

--Select Data we are using


select Location, date,total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country

select Location, date,total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total cases vs population
--Shows what percentage of population got Covid

select Location, date, total_cases, Population, (Total_cases/population)*100 as ContractionPercentage
from CovidPortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with highest infection rate compared to population

select Location, MAX(total_cases) as HighestInfectionCount, Population, MAX((Total_cases/population))*100 as ContractionPercentage
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
group by Location, Population
order by ContractionPercentage desc

--Looking at countries with highest death count per population

select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by HighestDeathCount desc


--Lets break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select date, Sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select Sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Counting per day

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



--Creating View to store for later Visualizations
create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated