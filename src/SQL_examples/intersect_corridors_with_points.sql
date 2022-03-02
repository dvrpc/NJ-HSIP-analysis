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