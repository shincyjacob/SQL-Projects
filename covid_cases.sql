-- data source : https://ourworldindata.org/covid-deaths
-- Data FROM 2020-01-01 to 2022-08-06 

SELECT *
FROM projects.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3 , 4; 

SELECT *
FROM projects.vaccination
WHERE continent IS NOT NULL
ORDER BY 3 , 4; 



-- Total cases and deaths worldwide

SELECT SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
FROM projects.coviddeaths
WHERE continent is not null 
ORDER BY 1,2;



SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM projects.coviddeaths
-- WHERE location like '%states%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Total Cases and death rate of a country every day basis
SELECT location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as deathrate
FROM projects.coviddeaths
WHERE location like 'INDIA'
and continent is not null 
ORDER BY 1,2;


-- What percentage of population is infected 
SELECT Location, date, Population, total_cases,  round((total_cases/population)*100,2) as infectedrate
FROM projects.coviddeaths
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) HighestInfectionCount,  round(Max((total_cases/population))*100,2) infectedrate
FROM projects.coviddeaths
GROUP BY Location, Population
ORDER BY infectedrate desc;
	-- above query with window function
SELECT location, Population, total_cases, round((total_cases/population)*100,2) as infectedrate
FROM
	(SELECT *, row_number() over (partition by location ORDER BY total_cases desc) as rn
	FROM projects.coviddeaths) t1
WHERE rn = 1
and continent is not null 
ORDER BY 4 desc;


-- Countries with Highest Death Count and total cases
SELECT Location, MAX(cast(Total_deaths as int)) as deathcount, MAX(Total_cases) as casecount
FROM projects.coviddeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY deathcount desc;
	-- above query using window function 
SELECT location, population, total_cases, cast(total_deaths as int) total_deaths, round((total_cases/population)*100,2) as infectedrate, round((total_deaths/population)*100,2) as deathrate
FROM
	(SELECT *, row_number() over (partition by location ORDER BY total_cases desc) as rn
	FROM projects.coviddeaths) t1
WHERE rn = 1
and continent is not null 
ORDER BY 4 desc;



-- contintents with the highest death count 
SELECT continent, MAX(cast(Total_deaths as int)) as deathcount
FROM projects.coviddeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY deathcount desc;



-- Percentage of Population that recieved at least one Covid Vaccine
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location ORDER BY d.location, d.Date) as peoplevaccinated
FROM projects.coviddeaths d
Join projects.covidvaccination v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent is not null 
ORDER BY 2,3

	-- Using CTE in previous query

With PopVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM projects.coviddeaths dea
Join projects.covidvaccination vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVac;



-- Using Temp Table for previous query

DROP Table if exists #PeopleVaccinated
CREATE Table #PeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)

Insert into #PeopleVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location ORDER BY d.location, d.Date) as peoplevaccinated
FROM projects.coviddeaths d
Join projects.covidvaccination v
	On d.location = v.location
	and d.date = v.date

SELECT *, (peoplevaccinated/Population)*100 vaccinated_rate
FROM #PeopleVaccinated
WHERE continent is not null 
ORDER BY 2,3;



-- vaccination rate of a country
SELECT d.Location, d.Population, MAX(cast(v.people_vaccinated as bigint)) as vac_count,  
round(Max((cast(v.people_vaccinated as bigint)/d.population))*100,2) as vaccinationrate
FROM projects.coviddeaths d
Join projects.covidvaccination v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent is not null 
GROUP BY d.Location, d.Population
ORDER BY vaccinationrate desc;

# Tableau visualization link :
-- https://public.tableau.com/app/profile/shincy.jacob/viz/CovidCases_16601357718600/Dashboard1


