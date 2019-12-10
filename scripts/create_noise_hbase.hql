-- create table holding top 5 noisiest nodes

create external table if not exists cmmurray_hbase_noise(
    row_num int,
    node_id string,
    db_sum float,
    db_count int,
    day_ct int
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,db:node_id,db:db_sum,db:db_ct,db:day_ct')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_noise');

INSERT OVERWRITE TABLE cmmurray_hbase_noise
SELECT ROW_NUMBER() OVER() AS row_num, * 
FROM
    (SELECT node_id,
    (db_sum/db_ct)/day_ct AS daily_avg
    FROM cmmurray_daily_noise
    WHERE day_ct > 14
    ORDER BY (db_sum/db_ct)/day_ct DESC)
limit 5;