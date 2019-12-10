## Workplan

### Overall architecture

#### Batch layer
- download all the CDPH complaints
    - ideally script this via API
    - ideally make the nearest node computation not a horrible cross join
- download and ingest more AoT data

#### Serving layer
- DONE noise_pollution: average decibels, complete
- DONE complaints: key is node, holds counts of complaints by type
- DONE nodes: just map the node_id to an address
- air_pollution: ?

#### Speed layer
- need to write Python script to query API and put results in Kafka
- need to write Scala scripts to listen to Kafka and put results in an HBase table
- current status + aggregate of last 24 hours or something?

#### Front end
- HTML for basic landing page
- Mustache template for displaying the data
    - would be cool to get this to show on a map?
- **drop down menu for node addresses**

### Tasks by priority

1. Build a speed layer
2. Build a drop down menu for the nodes
3. Fix complaints: avoid the cross join, look at complaints, drop some fields from hbase
4. Figure out about air pollution (probably compute some index in Scala)
