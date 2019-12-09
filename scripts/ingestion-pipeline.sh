# ingestion pipeline

# can you script pulling a git repo?

# get the data
sh scripts/ingest_aot.sh
sh scripts/ingest_complaints.sh

# put them in HDFS
hdfs dfs -mkdir /inputs/cmmurray/aot
hdfs dfs -mkdir /inputs/cmmurray/complaints
hdfs dfs -mkdir /inputs/cmmurray/nodes
hdfs dfs -put aot_data/AoT_Chicago.complete.recent.csv /inputs/cmmurray/aot/aot_chicago_recent.csv # change this!!
hdfs dfs -put aot_data/CDPH_Environmental_Complaints.csv /inputs/cmmurray/complaints/cdph_complaints.csv
hdfs dfs -put aot_data/chicago-2019-09/nodes.csv /inputs/cmmurray/nodes

# put these data in Hive
hive -f scripts/hive_sensor.hql
hive -f scripts/hive_nodes.hql

# NEED TO CALL SCALA SCRIPT FROM THE COMMAND LINE
spark-shell --conf spark.hadoop.metastore.catalog.default=hive
# CALL join_complaints_nodes.scala
# CALL aot scala script

#========================#
# CREATE SERVING LAYER
#========================#

# create HBase tables
hbase shell
create 'cmmurray_hbase_node_names', 'info'
create 'cmmurray_hbase_node_complaints', 'complaints'
# create AOT hbase table
exit

# move data from Hive into Hbase
hive -f scripts/create_node_names_hbase.hql
hive -f scripts/create_complaints_hbase.hql