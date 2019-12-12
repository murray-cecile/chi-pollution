create table if not exists cmmurray_hbase_master (
    address string,
    node_id string,
    node_vsn string,
    db_sum float,
    db_count int,
    db_max float,
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
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,info:node_id,db:db_sum,db:db_ct,db:db_max,complaints:air_pollution,complaints:asbestos,complaints:illegal_dumping,complaints:noise_complaint,complaints:vehicle_idling,complaints:recycling,complaints:water_pollution,complaints:storage_tanks,complaints:doe_tanks,complaints:toxic_materials,complaints:abandoned_site,complaints:construction_demolition,complaints:other')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_master');

INSERT OVERWRITE TABLE cmmurray_hbase_master
SELECT address,
    names.node_id,
    names.node_vsn,
    db_sum,
    db_count,
    db_max,
    air_pollution,
    asbestos,
    illegal_dumping,
    noise_complaint,
    vehicle_idling,
    recycling,
    water_pollution,
    storage_tanks,
    doe_permits,
    toxic_materials,
    abandoned_site,
    construction_demolition,
    other
FROM cmmurray_hbase_node_names AS names
     JOIN cmmurray_hbase_noise AS noise
    ON (names.node_id=noise.node_id)
     JOIN cmmurray_hbase_node_complaints AS complaints
    ON (complaints.node_id = noise.node_id);