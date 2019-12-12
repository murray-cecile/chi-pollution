create external table if not exists cmmurray_hbase_node_names (
    node_id string,
    address string,
    node_vsn string
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,info:address,info:node_vsn')
TBLPROPERTIES ('hbase.table.name' = 'cmmurray_hbase_node_names');

insert overwrite table cmmurray_hbase_node_names
select node_id, address, vsn from cmmurray_nodes;