import org.apache.spark.sql.SaveMode
import org.apache.spark.sql.functions.lower


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

// join complaints to nodes within 1km (EXPENSIVE CROSS JOIN, SORRY)
// approx degrees to km https://www.usna.edu/Users/oceano/pguth/md_help/html/approx_equivalents.htm
val node_complaints_sum = spark.sql(
"""
WITH nodes AS 
    (SELECT node_id, lat, lon 
    FROM cmmurray_nodes),
    complaints AS
    (SELECT complaint_id, complaint_type, latitude, longitude 
    FROM cmmurray_clean_complaints),
    distances AS
    (SELECT complaint_id, complaint_type, node_id,
    SQRT(POWER(latitude - lat, 2) + POWER(longitude - lon, 2)) as distance
    FROM complaints CROSS JOIN nodes)
SELECT node_id, 
COUNT(IF(complaint_type = "air pollution work order", 1, null)) as air_pollution,
COUNT(IF(complaint_type = "asbestos work order", 1,  null)) as asbestos,
COUNT(IF(complaint_type = "illegal dumping work order", 1, null)) as illegal_dumping,
COUNT(IF(complaint_type = "noise complaint", 1, null)) as noise_complaint,
COUNT(IF(complaint_type = "vehicle idling work order", 1, null)) as vehicle_idling,
COUNT(IF(complaint_type = "recycling work order", 1, null)) as recycling,
COUNT(IF(complaint_type = "water pollution", 1, null)) as water_pollution,
COUNT(IF(complaint_type = "service stations/storage tanks work order", 1, null)) as storage_tanks,
COUNT(IF(complaint_type = "permits issued by doe work order", 1, null)) as doe_permits,
COUNT(IF(complaint_type = "toxics hazardous materials doe work order", 1, null)) as toxic_materials,
COUNT(IF(complaint_type = "abandoned site", 1, null)) as abandoned_site,
COUNT(IF(complaint_type = "construction and demolition", 1, null)) as construction_demolition,
COUNT(IF(complaint_type = "other", 1, null)) as other
FROM distances
WHERE distance < 0.01
GROUP BY node_id
"""
)

node_complaints_sum.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_node_complaints")


// alternative version
// val complaints_by_node = spark.sql(
// """
// WITH nodes AS 
//     (SELECT node_id, lat, lon 
//     FROM cmmurray_nodes),
//     noise_complaints AS
//     (SELECT complaint_id, complaint_date, complaint_type,
//       complaint_detail, latitude, longitude 
//     FROM cmmurray_clean_complaints
//     WHERE complaint_type = "noise complaint"),
//     distances AS
//     (SELECT complaint_id, complaint_date, complaint_type, complaint_detail, 
//      node_id, SQRT(POWER(latitude - lat, 2) + POWER(longitude - lon, 2)) as distance
//     FROM noise_complaints 
//     CROSS JOIN nodes)
// SELECT node_id, complaint_date, complaint_detail
// FROM distances
// WHERE distance < 0.02
// """
// )

// complaints_by_node.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_complaints_by_node")


//  select node_id, count(complaint_detail) from cmmurray_complaints_by_node 
//  where year(from_unixtime(unix_timestamp(complaint_date, "mm/dd/YYYY"))) = 2019
//  group by node_id;
