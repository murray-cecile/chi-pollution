create external table if not exists cmmurray_hbase_node_names (
    node_id string,
    address string
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,info:address')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_node_names');

insert overwrite table cmmurray_hbase_node_names
select node_id, address from cmmurray_nodes;