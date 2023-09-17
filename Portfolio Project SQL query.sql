
Select * from PortfolioProject..CovidDeaths
Select * from PortfolioProject..CovidVaccinations 

Select * from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Looking at Total Cass vs Total Deaths in the United States
-- Show the likelihood of dying if you catch Covid in the United States 
Select Location, date, total_cases, total_deaths,
Concat (Round((total_deaths/total_cases)*100,2), ' %') as death_percentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
And continent is not null
Order by 2

--Looking the total cases vs the population
--Show the percentage of the population that got covid
Select Location, date, population, total_cases,
Concat ((total_cases/population)*100, ' %') as covid_percentage_from_the_population
from PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Countries with the highest infection rate compared to population
Select Location, population, Max(total_cases) as total_cases_count,
Max(total_cases/population)*100 as max_cases_percentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by 4 desc


--Looking at Continents with the highest infection count
Select continent, Max(total_cases) as total_cases_count
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by 2 desc

--Global Numbers
Select date, Sum(total_cases) as totalCases, Sum(total_deaths) as totalDeaths,
Concat((Sum(total_deaths)/Sum(total_cases))*100,' %') as death_percentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1


--Using CTE
With PopVsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
as (
--Looking at Total Population vs vaccinations
Select D.continent, D.location, D.date, D.population, new_vaccinations,
SUM(V.new_vaccinations) OVER (Partition by D.Location ORDER BY D.Location,D.date)
as total_vaccinations
from PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
   On D.location = V.location
   And D.date = V.date
WHERE D.continent is not null)
SELECT *,(total_vaccinations/population)*100 as percentage_of_the_population_vaccinated
FROM PopVsVac


-- Using temp table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated;

CREATE TABLE #PercentagePopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    total_vaccinations NUMERIC
);

INSERT INTO #PercentagePopulationVaccinated
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(V.new_vaccinations) OVER (PARTITION BY D.Location ORDER BY D.Location, D.date) AS total_vaccinations
FROM
    PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccinations V
    ON D.location = V.location
    AND D.date = V.date;

SELECT
    *,
    (total_vaccinations / population) * 100 AS percentage_population_vaccinated
FROM
    #PercentagePopulationVaccinated;

--Creating view to sore data for later visualizations
Create View PercentagePopulationVaccinated as 
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(V.new_vaccinations) OVER (PARTITION BY D.Location ORDER BY D.Location, D.date) AS total_vaccinations
FROM
    PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccinations V
    ON D.location = V.location
    AND D.date = V.date
WHERE D.continent is not null


Select * 
from PercentagePopulationVaccinated



 


