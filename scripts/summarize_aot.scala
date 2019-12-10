import org.apache.spark.sql.SaveMode

// bring sensor table in
// val sensor = spark.table("cmmurray_sensor_csv")


// https://www.health.nsw.gov.au/environment/air/Pages/common-air-pollutants.aspx
val no2_sum = spark.sql(
    """
    SELECT node_id, 
    SUM(value_hrf) AS no2_sum,
    COUNT(value_hrf) AS no2_ct
    FROM cmmurray_sensor_csv
    WHERE sensor = "no2" AND
    value_hrf > 0
    GROUP BY node_id
    """
)

no2_sum.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_no2_sum")

val noise_sum = spark.sql(
    """
    select node_id,
    DAY(FROM_UNIXTIME(UNIX_TIMESTAMP(stamptime, 'yyyy/MM/dd HH:mm:ss'))) AS day,
    sum(value_hrf) as db_sum,
    count(value_hrf) as db_ct,
    max(value_hrf) as db_max
    from cmmurray_sensor_csv
    where sensor = "spv1840lr5h_b" and
    value_hrf is not null
    group by node_id, DAY(FROM_UNIXTIME(UNIX_TIMESTAMP(stamptime, 'yyyy/MM/dd HH:mm:ss')))
    """
)

noise_sum.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_noise_sum")