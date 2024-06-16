Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioProject..CovidDeaths
order by 1,2

-- total cases vs total Deaths in India

 Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percent
 From portfolioProject..CovidDeaths
 where location = 'India'
 order by 1,2

 -- total cases vs population

 Select Location, date, total_cases, population, (total_cases/population) * 100 as Infected_percent
 From portfolioProject..CovidDeaths
 where location = 'India'
 order by 1,2

 --countries with highest infected rate

 Select Location, population, MAX(total_cases) as highestinfectedrate, MAX((total_cases/population)) * 100 as Infected_population
 From portfolioProject..CovidDeaths
 group by Location, population
 order by Infected_population desc


 -- countries with highest death rate 

 Select Location, MAX(cast(total_deaths as float)) as highestdeathrate 
 From portfolioProject..CovidDeaths
 where continent is not null
 group by Location
 order by highestdeathrate desc

 -- by continent
 Select continent, MAX(cast(total_deaths as float)) as highestdeathrate 
 From portfolioProject..CovidDeaths
 where continent is not null
 group by continent
 order by highestdeathrate desc


 -- Global no.

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, (SUM(cast(new_deaths as float))/SUM(new_cases)) * 100 as death_percent
 From portfolioProject..CovidDeaths
 where continent is not null 
 order by 1,2
 
 -- CTE USE
 with PopvsVac (Continent, Location, date, Population, RollingPeopleVaccinated, new_Vaccinations)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
 from portfolioProject..CovidDeaths dea
 join portfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date	
 where dea.continent is not null
 --order by 2,3
 )
 select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 --TEMP TABLE
 
 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 
 
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
 from portfolioProject..CovidDeaths dea
 join portfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date	
 --where dea.continent is not null
 --order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated

 -- Creating View to store data for later visualizations

 Create view PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
 from portfolioProject..CovidDeaths dea
 join portfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date	
 where dea.continent is not null
 --order by 2,3

 select * 
 from PercentPopulationVaccinated