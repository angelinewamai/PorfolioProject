select *
from CovidDeaths
where continent is not NULL
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Select the data that we are going to use

Select Location, date, Total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows the likelihood of dying if you contrsct covid in your country
Select Location, date, Total_cases,total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
where continent is not NULL
order by 1,2

---Looking at the total cases vs population
--Shows the %of the population that got covid
Select Location, date, Population, Total_cases,(Total_cases/Population)*100 as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
order by 1,2

--Looking at countries with the highest infection rate compared to Population
Select Location, Population, MAX(Total_cases) as HighestINfectionCount, MAX((Total_cases/Population))*100 as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by Location, Population
order by PopulationPercentageInfected Desc




--Showing countries with the highest Death count Per Population
Select Location,  MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by Location
order by TotalDeathCount Desc



----LETS BREAK THINGS DOWN BY CONTINENT


--Showing the continents with the highest Death Count per population
Select Continent,  MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by Continent
order by TotalDeathCount Desc

--Breaking Global numbers
Select date, SUM(New_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_deaths ,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group By Date
order by 1,2

--For the aggregate numbers Totalcases Vs Total Deaths as a percentage
Select  SUM(New_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_deaths ,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
--Group By Date
order by 1,2

---------------------------------------------------------------
---Joining the Two Tables - Deaths and Vaccinations

Select *
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location=vac.location
	and dea.date=vac.date


----Looking at the total population vs Vaccination per day
---ONe can use CONVERT instead of Cast by for NCHAR values--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--Use CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


---TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric 
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location=vac.location
	and dea.date=vac.date
--where dea.continent is not NULL
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 