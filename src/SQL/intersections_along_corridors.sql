select
	c.objectid,
	count(i.*),
	array_agg(i.rank::int) as mporank,
	min(i.rank::int) as top_mporank,
	array_agg(i.countyrank::int) as countyrank,
	min(i.countyrank::int) as top_countyrank

from
	transportation.hsip_corridor_2019 c

left join
	transportation.hsip_intersections_2019 i
	on st_dwithin(i.shape, c.shape, 30.48)

group by c.objectid
order by count(i.*) desc