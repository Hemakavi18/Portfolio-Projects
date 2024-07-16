SELECT * 
FROM [Portfolio Project]..Covid_dead
Order by 3, 4

SELECT * 
FROM [Portfolio Project]..Covid_Vaccination
Order by 3, 4

--Find the required data in the dataset.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_dead
order by 1, 2

-- Looking at Total cases vs Total deaths (percentage of population covid

SELECT location, date, population, total_cases,  (total_cases/population) * 100 As Percentage_covid
FROM Covid_dead
WHERE location LIKE '%ndia'
order by 1, 2

--Looking at countries with highest infection based on population

SELECT location, Max (population) As Max_population, Max (total_cases) As Max_infection, MAX(total_cases/population) * 100 As Max_percentage_infection
FROM Covid_dead
group by location
order by 4 desc

--Let Break the thing down continents

SELECT continent, Max (population) As Max_population, Max (total_cases) As Max_infection, MAX(total_cases/population) * 100 As Max_percentage_infection
FROM Covid_dead
group by continent
order by 4 desc

--Looking at countries with highest deaths based on population

SELECT location, Max (population) As Max_population, Max (total_deaths) As Max_deaths
FROM Covid_dead
Where continent iS NOT NULL
Group by location
order by Max_deaths desc
-- data type
ALTER TABLE Covid_dead
ALTER COLUMN total_deaths INT NULL

ALTER TABLE Covid_dead
ALTER COLUMN date DATE NULL

--Let Break the thing down continents

SELECT continent, Max (population) As Max_population, Max (total_deaths) As Max_deaths
FROM Covid_dead
Where continent iS NOT NULL
Group by continent
order by Max_deaths desc

--Global Numbers

SELECT SUM(new_cases) AS total_case, SUM(new_deaths) AS Global_total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS Percentag_deaths_rate
FROM Covid_dead
WHERE continent IS NOT NULL

--JOIN the two tables
SELECT *
FROM Covid_dead cd JOIN Covid_vaccination cv ON cd.continent = cv.continent AND cd.date = cv.date

-- Looking Total population vs Vaccination

SELECT cd.location, Max(cd.population) AS total_population,Max(cv.total_vaccinations) AS highest_vaccination
FROM Covid_dead cd JOIN Covid_vaccination cv ON cd.continent = cv.continent AND cd.date = cv.date
WHERE cd.continent is NOT Null
Group by cd.location
order by 2 desc, 3 desc

--Running total vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CONVERT(int, cv.new_vaccinations)) OVER (partition by cd. location order by cd.location, cd.date) As Running_total
FROM Covid_dead cd JOIN Covid_vaccination cv ON cd.continent = cv.continent AND cd.date = cv.date
WHERE cd.continent is NOT Null

--Running Average using CTE
WITH Popvsvac (Continent, Location, Date, Population, New_vaccination, Running_vacation)
AS
(
SELECT DISTINCT cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations,SUM(Convert (float, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date) As Running_total
FROM Covid_dead cd JOIN Covid_vaccination cv ON cd.continent = cv.continent AND cd.date = cv.date
WHERE cd.continent is NOT Null
)
SELECT *, Running_vacation/Population * 100 As Running_AVg
FROM Popvsvac
Order By 2, 3

-- Create temp table

CREATE TABLE #Vaccination 
(Continent VARCHAR(100), Location VARCHAR(100), Date DATETIME, Population float, New_vaccination float, Running_vacation float)

INSERT INTO #Vaccination (Continent, Location, Date, Population, New_vaccination)
SELECT cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations--,SUM(Convert (float, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date) As Running_total
FROM Covid_dead cd JOIN Covid_vaccination cv ON cd.continent = cv.continent AND cd.date = cv.date
WHERE cd.continent is NOT Null

SELECT * FROM #Vaccination 

--Create View

CREATE VIEW [Max_deaths] As
SELECT continent, Max (population) As Max_population, Max (total_deaths) As Max_deaths
FROM Covid_dead
Where continent iS NOT NULL
Group by continent
--order by Max_deaths desc

SELECT * FROM Max_deaths
--Creat storage

CREATE Procedure Continent_death AS
SELECT continent, Max (population) As Max_population, Max (total_deaths) As Max_deaths
FROM Covid_dead
Where continent iS NOT NULL
Group by continent
--order by Max_deaths desc
GO

EXEC Continent_death







