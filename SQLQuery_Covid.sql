-- Select Data that we are going to be using
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [dbo].[CovidDeath]
WHERE continent is NOT NULL
order by 1,2

-- Looking at total Cases vs total deaths
-- calculate the likehood of dying if your contract covid in your country
SELECT Location,date,total_cases,new_cases,total_deaths,ROUND((total_deaths/total_cases) *100,5) as Deathpercentage
FROM [dbo].[CovidDeath]
WHERE continent is NOT NULL
order by 1,2

-- looking at total cases vs population
SELECT Location,date,total_cases,population,ROUND((total_cases/population) *100,5) as casepercentage,ROUND((total_deaths/total_cases) *100,5) as Deathpercentage
FROM [dbo].[CovidDeath]
WHERE continent is NOT NULL
order by 1,2

-- Looking at Countries with highest infection rate compare to population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population) *100) as HighestInfectionRate
FROM [dbo].[CovidDeath] 
WHERE continent is NOT NULL
GROUP BY location,population
Order BY 4 DESC

-- look at peak infectionrate date in each country
with t2 as(
SELECT date,Location,population,new_cases,total_cases,(total_cases/population) *100 as Infection_rate
FROM [dbo].[CovidDeath] 
WHERE continent is NOT NULL),
t3 as(
SELECT * ,DENSE_RANK() over (partition by location order by infection_rate DESC) as rank FROM t2)

SELECT date as peak_date,location,infection_rate 
FROM t3
WHERE rank=1

-- showing country have highest death count per population
SELECT Location,MAX(cast(total_deaths as bigint)) as TotalDeathCournt
FROM [dbo].[CovidDeath] 
WHERE continent is NOT NULL
GROUP BY location
ORDER BY 2 desc
-- check result, some unwanted columns appears like world,asia....
-- solution WHERE continent is NOT NULL add to every script

-- check continent information 
SELECT location,MAX(cast(total_deaths as bigint)) as TotalDeathCournt
FROM [dbo].[CovidDeath] 
WHERE continent is NULL
GROUP BY location
ORDER BY 2 desc

-- showing contintents with highest death count
SELECT continent,MAX(cast(total_deaths as bigint)) as TotalDeathCournt
FROM [dbo].[CovidDeath] 
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 2 desc

-- Breaking Global Numbers
SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as bigint)) as total_death,SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as Deathpercentage
FROM [dbo].[CovidDeath]
WHERE continent is NOT NULL
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as bigint)) as total_death
FROM [dbo].[CovidDeath]
WHERE continent is NOT NULL

-- Vaccine section

-- look at total vaccination and population

with t1 (contient,location,date,population,new_vaccinations,cumulative_vaccinations)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint, cv.new_vaccinations)) 
OVER (Partition by cd.location ORDER BY cd.location, CONVERT(date, cd.date)) AS cumulative_vaccinations
FROM [dbo].[CovidDeath] cd
JOIN [dbo].[CovideVaccine] cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null 
)

SELECT *,(cumulative_vaccinations/population)*100 vaccincation_percentage
FROM t1

-- Creating View to store data for later
Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint, cv.new_vaccinations)) 
OVER (Partition by cd.location ORDER BY cd.location, CONVERT(date, cd.date)) AS cumulative_vaccinations
FROM [dbo].[CovidDeath] cd
JOIN [dbo].[CovideVaccine] cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null

SELECT * FROM [dbo].[CovideVaccine]

-- look at % of people_fully_vaccinated,% of total_booster per counrty
SELECT cd.continent, cd.location, cd.date, cd.population, cv.people_fully_vaccinated, cast(cv.people_fully_vaccinated as bigint)/cd.population *100 as per_fully_vac,cv.total_boosters,cv.total_boosters/cd.population as per_booster
FROM [dbo].[CovidDeath] cd
JOIN [dbo].[CovideVaccine] cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent is not null


