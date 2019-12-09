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

# SHOULD I BE USING SPARK/SCALA, PROBABLY...
spark-shell --conf spark.hadoop.metastore.catalog.default=hive


# create HBASE tables
hbase shell
create  'cmmurray_hbase_node_complaints', 'complaints'
exit