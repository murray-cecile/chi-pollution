create external table if not exists cmmurray_hbase_node_complaints(
    node_id string,
    air_pollution int,
    asbestos int,
    illegal_dumping int,
    noise_complaint int,
    vehicle_idling int,
    recycling int,
    water_pollution int,
    storage_tanks int,
    doe_permits int,
    toxic_materials int,
    abandoned_site int,
    construction_demolition int,
    other int
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,complaints:air_pollution,complaints:asbestos,complaints:illegal_dumping,complaints:noise_complaint,complaints:vehicle_idling,complaints:recycling,complaints:water_pollution,complaints:storage_tanks,complaints:doe_tanks,complaints:toxic_materials,complaints:abandoned_site,complaints:construction_demolition,complaints:other')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_node_complaints');


insert overwrite table cmmurray_hbase_node_complaints
select * from cmmurray_node_complaints;
 