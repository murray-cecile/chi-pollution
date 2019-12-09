create external table if not exists cmmurray_hbase_node_complaints(
    node_id string,
    complaint_type string,
    count int
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,complaints:complaint_type,complaints:count')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_node_complaints');


insert overwrite table cmmurray_hbase_node_complaints
select * from cmmurray_node_complaints;
 