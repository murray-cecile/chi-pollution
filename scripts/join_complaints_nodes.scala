import org.apache.spark.sql.SaveMode
import org.apache.spark.sql.functions.lower

val complaints = spark.table("cmmurray_complaints")
val nodes = spark.table("cmmurray_nodes")

// filter out complaints with 0 latitude and longitude
// set everything to standard case
val clean_complaints = spark.sql(
    """
    SELECT complaint_id, LOWER(complaint_type) AS complaint_type,
     complaint_date, complaint_detail, latitude, longitude
    FROM cmmurray_complaints
    WHERE latitude != 0 AND longitude !=0
    """
)

clean_complaints.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_clean_complaints")

// join complaints to nodes within 1km
// THIS IS HORRIBLE AND I'M SORRY
// https://www.usna.edu/Users/oceano/pguth/md_help/html/approx_equivalents.htm
val node_complaints = spark.sql(
"""
WITH nodes AS 
    (SELECT node_id, lat, lon FROM cmmurray_nodes),
    complaints AS
    (SELECT complaint_id, complaint_type, latitude, longitude FROM cmmurray_clean_complaints),
    distances AS
    (SELECT complaint_id, complaint_type, node_id,
    SQRT(POWER(latitude - lat, 2) + POWER(longitude - lon, 2)) as distance
    FROM complaints CROSS JOIN nodes)
SELECT node_id, complaint_type, COUNT(complaint_id) as complaint_count
FROM distances
WHERE distance < 0.01
GROUP BY node_id, complaint_type
"""
)

node_complaints.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_node_complaints")


