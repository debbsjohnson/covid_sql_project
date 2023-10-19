-- SELECT * FROM coviddeaths;



SELECT * 
FROM covidDeaths
where continent is not null
order by 3, 4;


-- SELECT * 
-- FROM covidVaccinations
-- order by 3, 4;


-- select data we're going to be using

select "location", date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;


-- looking at the total_cases versus total_deaths

select "location", date, total_cases, total_deaths, (total_deaths::numeric/total_cases)*100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2;

select "location", date, total_cases, total_deaths, (total_deaths::numeric/total_cases)*100 as population_infected_percentage
from coviddeaths
where "location" like '%States%'
and continent is not null
order by 1,2;



-- looking at total_cases versus population
-- shows what percentage of population got covid

select "location", date, total_cases, population, (total_cases::numeric/population)*100 as death_percentage
from coviddeaths
where "location" like '%States%'
and continent is not null
order by 1,2;


-- what countries have the highest infection rates compared to the population
select "location",  population, max(total_cases) as highest_infection_count,  max((total_cases::numeric/population))*100 as population_infected_percentage
from coviddeaths
group by "location", population
order by population_infected_percentage desc;


-- showing the countries with the highest death count per population
select "location", max(cast(total_deaths as bigint)) as total_death_count
from coviddeaths
where continent is not null
group by "location"
order by total_death_count desc;



-- let's break things down by continent

-- showing continents with the highest death count per population
select "location", max(cast(total_deaths as bigint)) as total_death_count
from coviddeaths
where continent is null
group by "location"
order by total_death_count desc;

-- global numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,	
	case
		when sum(new_cases) = 0 then 0 -- avoid division by zero
 		else (sum(new_deaths)::numeric / sum(new_cases)) * 100 
	end as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1,2;


select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,	
	case
		when sum(new_cases) = 0 then 0 -- avoid division by zero
 		else (sum(new_deaths)::numeric / sum(new_cases)) * 100 
	end as death_percentage
from coviddeaths
where continent is not null
order by 1,2;



-- looking at total population versus vaccinations

select * 
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location)
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,
  dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;







-- use cte

with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (rolling_people_vaccinated::numeric / population) * 100
from popvsvac;



-- temp table

drop table if exists percent_population_vaccinated;
create temp table percent_population_vaccinated
(
	continent varchar(40),
	location varchar(40),
	date varchar(40),
	population bigint,
	new_vaccinations int,
	rolling_people_vaccinated numeric
);


insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;
-- where dea.continent is not null;

select *, (rolling_people_vaccinated::numeric / population) * 100
from percent_population_vaccinated;





-- creating a view to store data for later visualizations

create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;





















