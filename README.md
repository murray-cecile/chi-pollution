## README: Listening to the Chicago Array of Things 

Final project for MPCS 53014: http://34.66.189.234:3686/aot-app.html

### About the data

The project relies on two data sources. 

First, the Chicago [Array of Things](https://api.arrayofthings.org/), or AoT, is a sensor network maintained by Univeristy of Chicago in collaboration with Argonne National Laboratories. The network consists of more than a hundred sensors mounted on streetlights around the city. These sensors track temperature, humidity, noise levels, light levels, air quality, and a number of other metrics. In a sense, these sensors are a pulse for the city. 

Second, the Chicago Department of Public Health maintains [a dataset of environmental complaints](https://data.cityofchicago.org/Environment-Sustainable-Development/CDPH-Environmental-Complaints/fypr-ksnz) going back to 1993. The data include noise complaints, which are featured in this app, but also include air pollution work orders and a range of other complaint types that could be productive avenues for further study in conjunction with the AoT data.

### Installation and setup

These instructions are designed for the class cluster environment, which has the necessary tools installed (HDFS, Hive, HBase, Kafka, Spark, node.js, etc). After cloning this repository, proceed according to the following steps:

#### Assemble the data

First, download the Chicago Department of Public Health Environmental Complaints dataset from [here](https://data.cityofchicago.org/Environment-Sustainable-Development/CDPH-Environmental-Complaints/fypr-ksnz]) and put it in the complaints/ subdirectory. I downloaded the file on my local machine and moved it across using the command stored in `scripts/ingest-complaints.sh`.

Subsequently, running the `ingestion-pipeline.sh` file in the scripts subdirectory will download the historical AoT data for January through September 2019 and put it in HDFS. It will also put the complaints data and node meta in HDFS.

#### Create the batch layer

Next, create the master raw data tables using three Hive scripts. 

`hive -f scripts/hive_sensor.hql` will create a table containing the sensor data.
`hive -f scripts/hive_nodes.hql` will create a table containing the node metadata.
`hive -f scripts/hive_complaints.hql` will create a table containing the complaints data.

To update the batch layer layer, add new data to or replace existing data in the corresponding subdirectories in HDFS (/inputs/cmmurray/aot, /inputs/cmmurray/complaints, inputs/cmmurray/nodes). 

#### Create the serving layer

This step involves some data cleaning. Subsequent versions of this app could be improved with less blunt data cleaning approaches. 

##### Summarizing the AoT noise data

Enter the spark shell with `spark-shell --conf spark.hadoop.metastore.catalog.default=hive`. Run the commands in 
scripts/summarize_aot.scala. This creates a Hive table called cmmurray_noise_sum.

This step filters the sensor master table to identify rows with the appropriate audio sensor where the measurement is not null and aggregates each measurement by node. The resulting table holds a sum of decibels and a count of observations, which enables the web app to calculate an average.

##### Summarizing the CDPH data

As in the last step, enter the Spark shell with `spark-shell --conf spark.hadoop.metastore.catalog.default=hive` and run the commands in scripts/join_complaints_nodes.scala.

This step first standardizes the case of all complaint types and drops observations with no location information. Then it filters only noise complaints and determines the distance between each complaint and each node, keeping only those within 0.01 degree (approximately 1 kilometer). It aggregates the number of each complaints within 1 km of each node. 

Note that this approach is a computationally expensive cross join approach that is feasible only because there are relatively few complaints and nodes. A better approach would be to use geospatial libraries to create a one kilometer buffer around the point location of each node and then perform a spatial join (e.g. in geopandas). Such libraries use more computationally efficient algorithms.

##### Creating the master HBase tables

The app relies on two HBase tables: cmmurray_hbase_master (for all data, including what flows in from the speed layer) and cmmurray_hbase_nodes (for node metadata).

Create these tables in the HBase shell with the following commands:

```
hbase shell
create 'cmmurray_hbase_nodes', 'info'
create 'cmmurray_hbase_master', 'info', 'db', 'complaints'
exit
```

Then populate the tables using the following Hive scripts:

```
hive -f scripts/create_nodes_hbase.hql
hive -f scripts/create_master_hbase.hql
```

#### Speed layer

To run the speed layer, you need the aot-speed-layer Uber jar file. 

The speed layer simply queries the AoT API endpoint for the latest measurements for the appropriate audio sensor. It updates two fields in the master table: one that holds the time at which the measurement was taken and one that holds the actual measurement.

Since the AoT provides monthly data dumps that are a historical data source, this application does not store old values for these current fields. In a more developed form, the app could cache these values in another table to use as a stopgap before a given month's data dump becomes available.

### Running the app

To run the app, follow these steps:

1. Start the Spark Streaming job to consume the data streaming in from the AoT API through Kafka. Do this on the cluster name node with:

`nohup spark-submit --class StreamNoise uber-aot-speed-layer-0.0.1-SNAPSHOT.jar mpcs53014c10-m-6-20191016152730.us-central1-a.c.mpcs53014-2019.internal:6667 > logs/spark_stream.out &`

2. In another terminal window, enter the Python 3 virtual environment on the name node and start streaming data in from the AoT API into Kafka:

```
source .\venv\bin\activate
nohup python scripts/query_api.py > logs/api_query.out &
```

3. Log into the webserver node and run the `run-webapp.sh` script. This script will install the npm dependencies and run the app.

`nohup sh scripts/run-webapp.sh > logs/webapp.out &`
