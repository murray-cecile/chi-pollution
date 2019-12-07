## Workplan

### Batch layer
- download all the CDPH complaints (ideally script this via API)
    - script out the cleaning: convert complaint type to lowercase
    - compute distance to nearest AoT node
- download some/all of the AoT data
- one table needs to be the AoT nodes + locations + "names/addresses"

### Serving layer
- noise_pollution: holds cumulative noise pollution by node for past X time period
- air_pollution: holds cumulative air pollution (?) by node for past X time period
- complaints: holds counts of complaints by closest node

### Speed layer
- need to write Python script to query API and put results in Kafka
- need to write Scala scripts to listen to Kafka and put results in an HBase table
- current status + aggregate of last 24 hours or something?

### Front end
- HTML for basic landing page
- Mustache template for displaying the data
    - would be cool to get this to show on a map
- **some kind of user interactivity**