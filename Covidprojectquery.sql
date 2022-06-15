--Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CAST(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from CovidDeaths
WHERE location like '%States%'
Order by 1,2 


--Shows what % of population got covid
Select location, date, total_cases, population, (CAST(total_cases as decimal)/population)*100 as PercentPopulationInfected
from CovidDeaths
WHERE location like '%States%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as decimal)/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%States%'
GROUP BY location, population
order by PercentPopulationInfected desc

--Showing countries with Highest Death count per population
Select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
Where location is not null
GROUP BY location
order by TotalDeathCount desc

--Let's breaking things into continent
Select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
Where continent is null
GROUP BY location
order by TotalDeathCount desc
--Showing continents with highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Global numbers
Select  SUM(new_cases) as total_newcases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
WHERE continent is not null
--GROUP BY date

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated, --(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
Join CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
order by 1,2,3

--use CTE
With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated )
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
Join CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

OR USE THIS 
CREATE TABLE PercentagePopulationVaccinated
(
continent VARCHAR(250),
location VARCHAR(250),
date TIMESTAMP,
population bigint,
new_vaccinations bigint,
RollingPeopleVaccinated bigint
)

INSERT INTO PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
Join CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 1,2,3

Select *, (CAST(RollingPeopleVaccinated as decimal)/population)*100
from PercentagePopulationVaccinated

