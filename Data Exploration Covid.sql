/* COVID DATA EXPLORATION */

Select *
From CovidCasesPH..CovidDeath
Order By 3,4

Select *
From CovidCasesPH..CovidDeath
Where location = 'Philippines'
Order By 3,4

Select Location, Date, population, total_cases, new_cases, total_deaths
From CovidCasesPH..CovidDeath
Order By 1,2

--Total Cases VS Total Deaths (PH)

Select location, date, total_cases, total_deaths, (cast(total_deaths as decimal) / cast(total_cases as decimal))*100 DeathPercentage
From CovidCasesPH..CovidDeath
Order by 1, 2

Select location, date, total_cases, total_deaths, (cast(total_deaths as decimal) / cast(total_cases as decimal))*100 DeathPercentage
From CovidCasesPH..CovidDeath
Where location = 'Philippines'
Order by 1, 2

--Total Cases VS Population (PH)

Select location, date, total_cases, population, (cast(total_cases as decimal) /(population))*100 InfectionRate
From CovidCasesPH..CovidDeath
Where location = 'Philippines'
Order by 1, 2


-- Comparison of Infection Rate of All Country

Select location, Max(total_cases) CountryTotalCase , population, (Max(cast(total_cases as decimal) /(population)))*100 InfectionRate
From CovidCasesPH..CovidDeath
Group by location, Population
Order by 4 desc

-- Comparison of Total Deaths of All Country

Select location, Max(convert(int, total_deaths)) CountryTotalDeath
From CovidCasesPH..CovidDeath
Where continent is not null
Group by location
Order by 2 desc


-- Comparison of Total Deaths per Continent

Select location, Max(convert(int, total_deaths)) ContinentTotalDeath
From CovidCasesPH..CovidDeath
Where continent is null
Group by location
Order by 2 desc

---Showing continents with the highest death count per population		

Select continent, Max(convert(int, total_deaths)) ContinentTotalDeath
From CovidCasesPH..CovidDeath
Where continent is not null
Group by continent
Order by ContinentTotalDeath desc


--Global Death Per Day

Select date, sum(new_cases) GlobalCasePerDay, sum(convert(decimal, new_deaths)) GlobalDeathPerDay,
(sum(convert(decimal, new_deaths))/sum(new_cases))*100 DeathPercentage
From CovidCasesPH..CovidDeath
where continent is not null
and new_cases <> 0
Group by date
Order by 1,2 

--Global Cases VS Global Death

Select sum(new_cases) GlobalCasePerDay, sum(convert(decimal, new_deaths)) GlobalDeathPerDay,
(sum(convert(decimal, new_deaths))/sum(new_cases))*100 DeathPercentage
From CovidCasesPH..CovidDeath
where continent is not null
and new_cases <> 0
Order by 1,2 

--For Visualization
Select location, Max(convert(int, total_deaths)) CountryTotalDeath
From CovidCasesPH..CovidDeath
where location = 'afghanistan'
group by location

Select location, Max(convert(int, total_deaths)) CountryTotalDeath, iso_code, population,continent, Max(convert(int, total_cases)) CountryTotalCase
From CovidCasesPH..CovidDeath
Where continent is not null
Group by location,iso_code, population,continent
order by 2 desc

Select continent, Max(convert(int, total_deaths)) ContinentTotalDeath
From CovidCasesPH..CovidDeath
Where continent is not null
Group by continent
Order by ContinentTotalDeath desc

Select DATE
from CovidCasesPH..CovidDeath



--COVID VACCINATIONS

Select *
From CovidCasesPH..CovidVaccine CV
order by 3,4

Select *
From CovidCasesPH..CovidVaccine CV
Join CovidCasesPH..CovidDeath CD
	on CD.location = CV.location
	and CD.date = CV.date
Order by 3,4

--Vaccinations VS Total Population

Select CD.location, Sum(convert(decimal, CV.total_vaccinations)) total_vaccinations,
Sum(convert(decimal, CD.population)) population, 
(Sum(convert(decimal, CV.total_vaccinations))/Sum(convert(decimal, CD.population)))*100 VaccinationPercentage
From CovidCasesPH..CovidVaccine CV
Join CovidCasesPH..CovidDeath CD
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Group by CD.location
Order by 1


-- Total Population VS New_Vaccination


Select CD.continent, CD.location, CD.population, CV.new_vaccinations
From CovidCasesPH..CovidDeath CD
Join CovidCasesPH..CovidVaccine CV
	on CD.location = CV. location
	and CD.date = CV.date
Where CD.continent is not null
Order by 2,3

-- PH Population VS Vaccination

Select CD.continent, CD.date, CD.location, CD.population, CV.new_vaccinations
From CovidCasesPH..CovidDeath CD
Join CovidCasesPH..CovidVaccine CV
	on CD.location = CV. location
	and CD.date = CV.date
Where CD.continent is not null
	and CD.location = 'Philippines'
Order by 2,3

--Rolling count of new vaccinations in the PH

Select CD.continent, CD.date, CD.location, CD.population, CV.new_vaccinations
, Sum(convert(decimal, CV.new_vaccinations)) OVER (Partition by CD.location 
Order by CD.location, CD.date) TotalVaccinePerDay
From CovidCasesPH..CovidDeath CD
Join CovidCasesPH..CovidVaccine CV
	on CD.location = CV. location
	and CD.date = CV.date
Where CD.continent is not null
	and CD.location = 'Philippines'
Order by 3,2

--Use CTE

WITH CTEVAC (continent, date, location, population, new_vaccinations, TotalVaccinePerDay)
as
(
Select CD.continent, CD.date, CD.location, CD.population, CV.new_vaccinations,
Sum(convert(decimal, CV.new_vaccinations)) OVER (Partition by CD.location 
Order by CD.location, CD.date) TotalVaccinePerDay
From CovidCasesPH..CovidDeath CD
Join CovidCasesPH..CovidVaccine CV
	on CD.location = CV. location
	and CD.date = CV.date
Where CD.continent is not null
)


--Use Temp Table

DROP Table if exists #TempVac
Create Table #TempVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population float,
New_vaccinations nvarchar(255),
TotalVaccinationPerDay numeric
)
Insert into #TempVac
Select CD.continent, CD.date, CD.location, CD.population, CV.new_vaccinations,
Sum(convert(decimal, CV.new_vaccinations)) OVER (Partition by CD.location 
Order by CD.location, CD.date) TotalVaccinePerDay
From CovidCasesPH..CovidDeath CD
Join CovidCasesPH..CovidVaccine CV
	on CD.location = CV. location
	and CD.date = CV.date
Where CD.continent is not null

Select *
From #TempVac

--Creating View to store data for visualization

Create View ViewSample as 
Select CD.continent, CD.date, CD.location, CD.population, CV.new_vaccinations,
Sum(convert(decimal, CV.new_vaccinations)) OVER (Partition by CD.location 
Order by CD.location, CD.date) TotalVaccinePerDay
From CovidCasesPH..CovidDeath CD
Join CovidCasesPH..CovidVaccine CV
	on CD.location = CV. location
	and CD.date = CV.date
Where CD.continent is not null