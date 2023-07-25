// Data Exploration

Select *
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
Where continent is not null 
order by 3,4




-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT
  Location,Date,Total_Cases,Total_Deaths,(Total_Deaths / Total_Cases) * 100 AS DeathPercentage
FROM COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
WHERE
  Location LIKE 'United States'
  AND Continent IS NOT NULL
ORDER BY
  1, 2;



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
order by 1,2



-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS FOR NEW CASES 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`" dea
Join COVID_ANALYSIS.PUBLIC."`COVIDVACCINATIONS`" vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`" dea
Join COVID_ANALYSIS.PUBLIC."`COVIDVACCINATIONS`" vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);



Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`" dea
Join COVID_ANALYSIS.PUBLIC."`COVIDVACCINATIONS`" vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, case when PercentPopulationVaccinated.Population=0 THEN 0 ELSE (RollingPeopleVaccinated/Population)*100 END as Rolling_people_vaccinated
From PercentPopulationVaccinated

select count(*) from COVID_ANALYSIS.PUBLIC.PERCENTPOPULATIONVACCINATED
where PERCENTPOPULATIONVACCINATED.Rolling_people_vaccinated = 0.000000


-- Creating View to store data for later visualizations

Create View Percent_PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`" dea
Join COVID_ANALYSIS.PUBLIC."`COVIDVACCINATIONS`" vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 