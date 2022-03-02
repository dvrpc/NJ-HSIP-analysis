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

from transportation.hsip_corridor_2019 c

left join transportation.hsip_hrrr_2019 i
    on st_overlaps(i.shape, c.shape)
group by c.objectid
