-- create table to hold all of the sensor data

create external table if not exists cmmurray_nodes(
  node_id string,
  project_id string,
  vsn string,
  address string,
  lat float,
  lon float,
  description string,
  start_timestamp timestamp,
  end_timestamp timestamp
)   
row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = "\,",
  "quoteChar"     = "\""
)
STORED AS TEXTFILE
  location '/inputs/cmmurray/nodes'
TBLPROPERTIES ("skip.header.line.count"="1");