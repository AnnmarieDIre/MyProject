/* Covid 19 data exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate functions, Creating views, Converting data types

*/


select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4;


--Select Data to start with

select location,date, total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2;


--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in different countries

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2;

--Looking at Total Cases vs Deaths in Ireland
--Shows likelihood of dying if you contract Covid in Ireland

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Ireland'
and continent is not null
order by 1,2;


--Total Cases vs Population
--Shows what percentage of population infected with Covid

Select location,date, population,total_cases,(total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Ireland'
order by 1,2;


--Countries with highest infection rates compared to population

Select location, population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc;


--Showing Countries with Highest Death Count per Population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc;


--BREAKING THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc;


--GLOBAL NUMBERS

--Shows daily global cases and deaths globally
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2;


--Shows sum of total cases and deaths globally to date

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2;


--Total population vs vaccinations
--Shows percentage of population that has recieved at least one Covid Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Using CTE to perform calculation

With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * ,RollingPeopleVaccinated/population *100
From PopvsVac;


--Use temp table to perform calculation

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * ,RollingPeopleVaccinated/population *100
From #PercentPopulationVaccinated;

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


