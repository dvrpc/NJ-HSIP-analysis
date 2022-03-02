-- For a given ANALYSIS_CORRIDOR_TABLE,
-- 		1) find the number of and rank of each type of HSIP intersection within 100'
-- 		2) find the number, rank, and percent overlap of all other HSIP corridors that overlap
-- Return the result with the analysis corridor geometries and all spatial analysis results as columns

with all_intersections as (
	select
		c.objectid,
		count(i.*) as all_intersections,
		array_agg(i.rank::int) as all_mporank,
		min(i.rank::int) as all_top_mporank,
		array_agg(i.countyrank::int) as all_countyrank,
		min(i.countyrank::int) as all_top_countyrank
	
	from transportation.ANALYSIS_CORRIDOR_TABLE c

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
	
	from transportation.ANALYSIS_CORRIDOR_TABLE c
	
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
	
	from transportation.ANALYSIS_CORRIDOR_TABLE c
	
	left join transportation.hsip_pedintersections_2019 i
		on st_dwithin(i.shape, c.shape, 30.48)
	group by c.objectid
),
corridor_a as (
	select
		c.objectid,
		count(i.*) as a_intersections,
		array_agg(
			round(
				(st_length(st_intersection(i.shape, c.shape)) / st_length(c.shape) * 100)::numeric,
				2
			)
		) as a_pct_overlap,
		array_agg(i.rank::int) as a_mporank,
		min(i.rank::int) as a_top_mporank,
		array_agg(i.countyrank::int) as a_countyrank,
		min(i.countyrank::int) as a_top_countyrank
	
	from transportation.ANALYSIS_CORRIDOR_TABLE c
	
	left join transportation.OTHER_CORRIDOR_A i
		on st_overlaps(i.shape, c.shape)
	group by c.objectid
),
corridor_b as (
	select
		c.objectid,
		count(i.*) as b_intersections,
		array_agg(
			round(
				(st_length(st_intersection(i.shape, c.shape)) / st_length(c.shape) * 100)::numeric,
				2
			)
		) as b_pct_overlap,
		array_agg(i.rank::int) as b_mporank,
		min(i.rank::int) as b_top_mporank,
		array_agg(i.countyrank::int) as b_countyrank,
		min(i.countyrank::int) as b_top_countyrank
	
	from transportation.ANALYSIS_CORRIDOR_TABLE c
	
	left join transportation.OTHER_CORRIDOR_B i
		on st_overlaps(i.shape, c.shape)
	group by c.objectid
),
corridor_c as (
	select
		c.objectid,
		count(i.*) as c_intersections,
		array_agg(
			round(
				(st_length(st_intersection(i.shape, c.shape)) / st_length(c.shape) * 100)::numeric,
				2
			)
		) as c_pct_overlap,
		array_agg(i.rank::int) as c_mporank,
		min(i.rank::int) as c_top_mporank,
		array_agg(i.countyrank::int) as c_countyrank,
		min(i.countyrank::int) as c_top_countyrank
	
	from transportation.ANALYSIS_CORRIDOR_TABLE c
	
	left join transportation.OTHER_CORRIDOR_C i
		on st_overlaps(i.shape, c.shape)
	group by c.objectid
)
select
	i.objectid,
	i.all_intersections,
	i.all_mporank::text,
	i.all_top_mporank,
	i.all_countyrank::text,
	i.all_top_countyrank,
	pedbike.pedbike_intersections,
	pedbike.pedbike_mporank::text,
	pedbike.pedbike_top_mporank,
	pedbike.pedbike_countyrank::text,
	pedbike.pedbike_top_countyrank,
	ped.ped_intersections,
	ped.ped_mporank::text,
	ped.ped_top_mporank,
	ped.ped_countyrank::text,
	ped.ped_top_countyrank,
	a.a_intersections,
	a.a_pct_overlap::text,
	a.a_mporank::text,
	a.a_top_mporank,
	a.a_countyrank::text,
	a.a_top_countyrank,
	b.b_intersections,
	b.b_pct_overlap::text,
	b.b_mporank::text,
	b.b_top_mporank,
	b.b_countyrank::text,
	b.b_top_countyrank,
	c.c_intersections,
	c.c_pct_overlap::text,
	c.c_mporank::text,
	c.c_top_mporank,
	c.c_countyrank::text,
	c.c_top_countyrank,
	src.shape as geom
from
	all_intersections as i
left join
	pedbike_intersections as pedbike on i.objectid = pedbike.objectid
left join
	ped_intersections as ped on i.objectid = ped.objectid
left join 
	corridor_a as a on i.objectid = a.objectid
left join 
	corridor_b as b on i.objectid = b.objectid
left join 
	corridor_c as c on i.objectid = c.objectid
left join
	transportation.ANALYSIS_CORRIDOR_TABLE as src on i.objectid = src.objectid

