SELECT SERVERPROPERTY('Edition')
use PortfolioProject;

select * from CovidDeaths
order by 3,4;

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, 
CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN NULL
        ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 
    END AS DeathPercentage
from CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percetage of population got covid
Select Location, date, Population, total_cases, total_deaths, 
CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN NULL
        ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 
    END PercentagePopulationInfected
from CovidDeaths
where location like '%states%'
Order by DeathPercentage desc


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,
CASE 
        WHEN MAX(CAST(total_cases AS FLOAT)) = 0 THEN NULL
        ELSE (MAX(CAST(total_deaths AS FLOAT)) / MAX(CAST(total_cases AS FLOAT))) * 100 
    END AS PercentagePopulationInfected
from CovidDeaths
--where location like '%states%'
group by location, population
Order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE continent != ' '
group by location
Order by TotalDeathCount desc

-- LET's BREAK THINGS DOWN BY CONTINENT

-- Showing continent with highest death count per population
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE continent != ' '
group by continent
Order by TotalDeathCount desc



-- Global Numbers

Select date, sum(cast(new_cases as float)) as total_cases, sum(CAST(new_deaths as float)) as total_deaths,
CASE 
        WHEN sum(CAST(new_cases AS FLOAT)) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 
    END AS DeathPercentage
from CovidDeaths
where continent != ' '
Group by date
Order by 1,2


Select sum(cast(new_cases as float)) as total_cases, sum(CAST(new_deaths as float)) as total_deaths,
CASE 
        WHEN sum(CAST(new_cases AS FLOAT)) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 
    END AS DeathPercentage
from CovidDeaths
where continent != ' '
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location  = vac.location
	and dea.date = vac.date
where dea.continent != ' '
order by 2,3


-- USE CTE

with PopvsVac (Continet, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location  = vac.location
	and dea.date = vac.date
where dea.continent != ' '
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeoplVaccinated
from PopvsVac;

-- Temp Table
 
create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, 
       TRY_CAST(dea.population as numeric) as Population, 
       TRY_CAST(vac.new_vaccinations as numeric) as New_vaccinations,
       SUM(TRY_CAST(vac.new_vaccinations as numeric)) 
       over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ' ';

select *, 
    (RollingPeopleVaccinated / Population) * 100 as PercentagePeopleVaccinated
from #PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location  = vac.location
	and dea.date = vac.date
where dea.continent != ' '


Select *
From PercentPopulationVaccinated