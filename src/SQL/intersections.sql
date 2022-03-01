-- Find the number of and rank of each type of HSIP intersection along each HSIP corridor
-- Return the result as a joined table with all results, along with the corridor geometries

with all_intersections as (
	select
		c.objectid,
		count(i.*) as all_intersections,
		array_agg(i.rank::int) as all_mporank,
		min(i.rank::int) as all_top_mporank,
		array_agg(i.countyrank::int) as all_countyrank,
		min(i.countyrank::int) as all_top_countyrank
	
	from transportation.hsip_corridor_2019 c

	left join transportation.hsip_intersections_2019 i
		on st_dwithin(i.shape, c.shape, 30.48)
	group by c.objectid
),
pedbike_intersections as (
	select
		c.objectid,
		count(i.*) as pedbike_intersections,
		array_agg(i.rank::int) as pedbike_mporank,
		min(i.rank::int) as pedbike_top_mporank,
		array_agg(i.countyrank::int) as pedbike_countyrank,
		min(i.countyrank::int) as pedbike_top_countyrank
	
	from transportation.hsip_corridor_2019 c
	
	left join transportation.hsip_pedbikeintersections_2019 i
		on st_dwithin(i.shape, c.shape, 30.48)
	group by c.objectid
),
ped_intersections as (
	select
		c.objectid,
		count(i.*) as ped_intersections,
		array_agg(i.rank::int) as ped_mporank,
		min(i.rank::int) as ped_top_mporank,
		array_agg(i.countyrank::int) as ped_countyrank,
		min(i.countyrank::int) as ped_top_countyrank
	
	from transportation.hsip_corridor_2019 c
	
	left join transportation.hsip_pedintersections_2019 i
		on st_dwithin(i.shape, c.shape, 30.48)
	group by c.objectid
)
select
	i.*,
	pedbike.*,
	ped.*,
	c.shape
from all_intersections i
left join
	pedbike_intersections pedbike on i.objectid = pedbike.objectid
left join
	ped_intersections ped on i.objectid = ped.objectid 
left join
	transportation.hsip_corridor_2019 c on i.objectid = c.objectid

