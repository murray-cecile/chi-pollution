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
python3 -mvenv venv
source ./venv/bin/activate
pip install -r requirements.txt

# create a Kafka topic 
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:2181 --replication-factor 1 --partitions 1 --topic cmmurray

# send some messages
/usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667 --topic cmmurray

# consume messages from another terminal 
/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667 --topic cmmurray --from-beginning