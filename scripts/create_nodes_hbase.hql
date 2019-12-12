create external table if not exists cmmurray_hbase_nodes (
    node_vsn string,
    address string,
    node_id string
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,info:address,info:node_id')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_nodes');

insert overwrite table cmmurray_hbase_nodes
select vsn, address, node_id from cmmurray_nodes;