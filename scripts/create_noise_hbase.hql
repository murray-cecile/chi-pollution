-- create table holding top 5 noisiest nodes

create external table if not exists cmmurray_hbase_noise(
    node_id string,
    db_sum float,
    db_count int,
    db_max float
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,db:db_sum,db:db_ct,db:db_max')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_noise');

INSERT OVERWRITE TABLE cmmurray_hbase_noise
SELECT * FROM cmmurray_noise_sum;