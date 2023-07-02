--*/
select *
from [Portfolio Project]..[covid death ]
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with
select location,date,total_cases, total_deaths,new_cases,population
from [Portfolio Project]..[covid death ]
where continent is not null
order by 1,2



--information for data
select *
from INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'covid death'

--change type column
Alter Table [covid death]
Alter column total_cases float ;

ALTEr TABLE [covid death]
ALTER COLUMN total_deaths float ;

--looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
from [Portfolio Project]..[covid death ]
WHERE location like '%states%' and  continent is not null
order by 1,2

--looking at Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,population,total_cases , (total_cases/population)*100 AS PopulationPercentage
from [Portfolio Project]..[covid death ]
WHERE location like '%states%' and  continent is not null
order by 1,2

-- Loking at countries with Highest Infecr Rate compared to Population

SELECT location,population,max(total_cases) AS HighestInfectionCount , max(total_cases/population)*100 AS PopulationPercentage
from [Portfolio Project]..[covid death ]
--WHERE location like '%states%'
Group by location, population
order by PopulationPercentage desc


-- Showing Countries with Highest Dearh Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..[covid death ]
where continent is not null
group by location 
order by TotalDeathCount desc


--Let's Break things down by Continent

Select continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..[covid death ]
where continent is not null
group by continent 
order by TotalDeathCount desc



Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..[covid death ]
where continent is  null
group by location 
order by TotalDeathCount desc



Select continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..[covid death ]
where continent is  null
group by continent 
order by TotalDeathCount desc


-- Showing contintents with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..[covid death ]
where continent is not null
group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..[covid death ]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations ) over (partition by dea.Location order by dea.location , dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..[covid death ] dea
join[Portfolio Project]..[Covid Vaccinations] vac
	 on dea.location = vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3





--information for data
select *
from INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'covid vaccinations'

--change type column
Alter Table [covid vaccinations]
Alter column new_vaccinations float ;






-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[covid death ] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 





-- Using Temp Table to perform Calculation on Partition By in previous query

-- DROP Table if exists #PercentPopulationVaccinated   "to drop table and do some edit"

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
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[covid death ] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[covid death ] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated