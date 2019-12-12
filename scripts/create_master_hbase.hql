create table if not exists cmmurray_hbase_master (
    address string,
    node_id string,
    node_vsn string,
    db_sum float,
    db_count int,
    db_max float,
    -- air_pollution int,
    -- asbestos int,
    -- illegal_dumping int,
    noise_complaint int,
    -- vehicle_idling int,
    -- recycling int,
    -- water_pollution int,
    -- storage_tanks int,
    -- doe_permits int,
    -- toxic_materials int,
    -- abandoned_site int,
    -- construction_demolition int,
    -- other int,
    last_seen string,
    current_db string
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,info:node_id,info:node_vsn,db:db_sum,db:db_ct,db:db_max,complaints:noise_complaint,speed:last_seen,speed:current_db')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_master');

INSERT OVERWRITE TABLE cmmurray_hbase_master
SELECT address,
    names.node_id,
    names.node_vsn,
    db_sum,
    db_ct,
    db_max,
    noise_complaint,
    NULL,
    NULL
FROM cmmurray_hbase_nodes AS names
     JOIN cmmurray_noise_sum AS noise
    ON (names.node_id=noise.node_id)
     JOIN cmmurray_hbase_node_complaints AS complaints
    ON (complaints.node_id = noise.node_id);