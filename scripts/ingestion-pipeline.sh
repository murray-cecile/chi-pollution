# ingestion pipeline

# create some directories in hdfs
hdfs dfs -mkdir /inputs/cmmurray
hdfs dfs -mkdir /inputs/cmmurray/aot
hdfs dfs -mkdir /inputs/cmmurray/complaints
hdfs dfs -mkdir /inputs/cmmurray/nodes

# get the data
sh scripts/ingest_aot.sh
sh scripts/ingest_complaints.sh

# put complaints data in HDFS
hdfs dfs -put aot_data/CDPH_Environmental_Complaints.csv /inputs/cmmurray/complaints/cdph_complaints.csv
hdfs dfs -put aot_data/chicago-2019-09/nodes.csv /inputs/cmmurray/nodes # THIS IS MISSING IN THE NEW APPROACH

# put these data in Hive
hive -f scripts/hive_sensor.hql
hive -f scripts/hive_nodes.hql
hive -f scripts/hive_complaints.hql

