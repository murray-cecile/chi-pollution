# ingestion pipeline

# get the data
sh scripts/ingest_aot.sh
sh scripts/ingest_complaints.sh

# put them in HDFS
hdfs dfs -mkdir /inputs/cmmurray/aot
hdfs dfs -mkdir /inputs/cmmurray/complaints
hdfs dfs -mkdir /inputs/cmmurray/nodes
hdfs dfs -put aot_data/chicago-2019-09/data.csv.gz /inputs/cmmurray/aot # change this!!
hdfs dfs -put aot_data/CDPH_Environmental_Complaints.csv /inputs/cmmurray/complaints/cdph_complaints.csv
hdfs dfs -put aot_data/chicago-2019-09/nodes.csv /inputs/cmmurray/nodes

# put these data in Hive
hive -f scripts/hive_sensor.hql
hive -f scripts/hive_nodes.hql
hive -f scripts/hive_complaints.hql

#========================#
# CREATE SERVING LAYER
#========================#

# NEED TO CALL SCALA SCRIPT FROM THE COMMAND LINE
spark-shell --conf spark.hadoop.metastore.catalog.default=hive
# CALL join_complaints_nodes.scala
# CALL aot scala script

# create HBase tables
hbase shell
create 'cmmurray_hbase_node_names', 'info'
create 'cmmurray_hbase_node_complaints', 'complaints'
create 'cmmurray_hbase_noise', 'db'
# TO DO: create air pollutant hbase table?

create 'cmmurray_hbase_master', 'info', 'db', 'complaints'
exit

# move data from Hive into Hbase
hive -f scripts/create_node_names_hbase.hql
hive -f scripts/create_complaints_hbase.hql
hive -f scripts/create_noise_hbase.hql

#========================#
# CREATE SPEED LAYER
#========================#

# create virtual environment for Python package installation
python3 -mvenv chi-pollution
source ./chi-pollution/bin/activate
pip install requirements.txt