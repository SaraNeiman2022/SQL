/* 

- The table for these queries was created using the SSMS import/export tool.

- The dataset was downloaded as a csv from https://ourworldindata.org/covid-deaths

- Below queries show intially exploratory findings for dataset, and store aggregates 
  as both a temp table and as a view.

*/

--countries with highest death count vs population 

select location, max(cast(total_deaths as int)) TotalDeathCount
from covid_death
where continent is not null
group by location
order by TotalDeathCount desc


--continents with highest death count per  population 

select location, max(cast(total_deaths as int)) TotalDeathCount
from covid_death
where continent is null and location not like  '%incom%' and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;


--Total population vs population vaccinated per day
with t1 as
	(select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(cast(new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as total_new_vaccinations
from covid_death d
join CovidVaccinations v
on d.location =v.location 
and d.date = v.date
where d.continent is not null 
)

select * , (total_new_vaccinations/population)*100 as PercentVaccinated
from t1

--Create Temp table for further analysis

drop table if exists #PercentPopulationVaccinated
create table #Percentpopulationvaccinated 
		(continent nvarchar(255), 
		location nvarchar(255), 
		date datetime, 
		population numeric, 
		new_vaccinations numeric, 
		total_new_vaccinations numeric)

insert into #PercentPopulationVaccinated 
--Total population vs population vaccinated per day
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(cast(new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as total_new_vaccinations
from covid_death d
join CovidVaccinations v
on d.location =v.location 
and d.date = v.date
where d.continent is not null 

-- Store above temp table data as a view
create view PercentPopulationVaccinated as 
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(cast(new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as total_new_vaccinations
from covid_death d
join CovidVaccinations v
on d.location =v.location 
and d.date = v.date
where d.continent is not null 