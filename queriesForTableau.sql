/*

Queries used for Tableau Project

*/


-- 1. 


select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,	
	case
		when sum(new_cases) = 0 then 0 -- avoid division by zero
 		else (sum(new_deaths)::numeric / sum(new_cases)) * 100 
	end as death_percentage
from coviddeaths
where continent is not null
order by 1,2;



-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

select "location", sum(new_deaths) as total_death_count
from covidDeaths
where continent is null
and "location" not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income')
group by "location"
order by total_death_count desc;



-- 3.

select "location",  population, max(total_cases) as highest_infection_count,  max((total_cases::numeric/population))*100 as population_infected_percentage
from coviddeaths
group by "location", population
order by population_infected_percentage desc;


-- 4.


select "location",  population, date, max(total_cases) as highest_infection_count,  max((total_cases::numeric/population))*100 as population_infected_percentage
from covidDeaths
group by "location", population, date
order by population_infected_percentage desc;





