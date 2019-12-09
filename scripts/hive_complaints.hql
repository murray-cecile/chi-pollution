-- put complaints data into Hive

create external table if not exists cmmurray_complaints(
complaint_id string,
complaint_type string,
address string,
stnum_from string,
stnum_to string,
direction string,
street_name string,
street_type string,
inspector string,
complaint_date timestamp,
complaint_detail string,
inspection_log string,
data_source_string string,
date_modified timestamp,
latitude double,
longitude double,
location string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = "\,",
  "quoteChar"     = "\""
)
STORED AS TEXTFILE
  location '/inputs/cmmurray/complaints'
TBLPROPERTIES ("skip.header.line.count"="1");

-- next standardize case of complaint types
