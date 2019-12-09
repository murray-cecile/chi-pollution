## Workplan

### Batch layer
- download all the CDPH complaints
    - (ideally script this via API)
    - script out the cleaning in scala for intermediate table: 
        - drop 0's & convert complaint type to lowercase
        - compute distance to nearest AoT node (ideally would make this not a horrible cross join)
- download and ingest the AoT data
    - need to figure out what air pollution metric to use: N02 and O3 seem good
- get table mapping AoT nodes + locations + "names/addresses"

### Serving layer
- noise_pollution: holds cumulative noise pollution by node for past X time period
    - what is the schema for this table?
- air_pollution: holds cumulative air pollution (?) by node for past X time period
    - what is the schema for this table?
- DONE complaints: key is node, holds counts of complaints by type
- DONE nodes: just map the node_id to an address


### Speed layer
- need to write Python script to query API and put results in Kafka
- need to write Scala scripts to listen to Kafka and put results in an HBase table
- current status + aggregate of last 24 hours or something?

### Front end
- HTML for basic landing page
- Mustache template for displaying the data
    - would be cool to get this to show on a map
- **some kind of user interactivity**