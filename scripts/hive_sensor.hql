-- create ORC table to hold all of the sensor data

-- first, map CSV data into Hive
create external table cmmurray_sensor_csv(
  stamptime string,
  node_id string,
  subsystem string,
  sensor string,
  parameter string,
  value_raw float,
  value_hrf float
)   
row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = "\,",
  "quoteChar"     = "\""
)
STORED AS TEXTFILE
  location '/inputs/cmmurray/aot'
TBLPROPERTIES ("skip.header.line.count"="1");

-- test query
select stamptime, node_id, sensor, parameter, value_hrf from cmmurray_sensor_csv limit 5;

-- -- make ORC table
-- create table cmmurray_sensor (
--     time timestamp,
--     node_id string,
--     subsystem string,
--     sensor string,
--     parameter string,
--     value_raw float,
--     value_hrf float
-- )  stored as orc;

-- -- copy the csv data to the ORC table
-- insert overwrite table sensor select * from sensor_csv;