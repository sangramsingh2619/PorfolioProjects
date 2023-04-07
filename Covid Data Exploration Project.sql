-- Looking at the dataset
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM coviddeaths
ORDER BY 1,3,4;


-- Looking at total cases vs total deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location LIKE '%india%'
ORDER BY 1,3,4;

-- Looking at Total cases vs population
-- Shows what percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
FROM coviddeaths
WHERE location LIKE '%india%'
ORDER BY 1,3,4;

-- Looking at the highest number of covid infected compared to the population
SELECT location, MAX(total_cases) as HigestCases,population,MAX((total_cases/population))*100 as InfectedPercentage
FROM coviddeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;

-- Showing the countries with highest deaths
SELECT location, MAX(total_deaths) as HighestDeaths
FROM coviddeaths
WHERE location IS NOT NULL
GROUP BY location
ORDER BY HighestDeaths DESC;

-- BREAKING DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) as HighestDeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeaths DESC;

-- GLOBAL NUMBERS

SELECT
SUM(new_cases) as total_cases, 
SUM(CONVERT(new_deaths, signed)) as total_deaths, 
SUM(CONVERT(new_deaths, signed))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- (WHERE location LIKE '%india%')
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY date;


-- Looking at the total population vs vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations,UNSIGNED)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and
    dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2;

-- USING CTEs
WITH PopvsVac (Continent,location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations,UNSIGNED)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and
    dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Creating view to store data for later visualization

Create VIEW PercentagePeopleVaccinated
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations,UNSIGNED)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and
    dea.date = vac.date
WHERE dea.continent IS NOT NULL






