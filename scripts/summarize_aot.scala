import org.apache.spark.sql.SaveMode

// bring sensor table in
val sensor = spark.table("cmmurray_sensor_csv")

spark.sql(
    """
    select distinct parameter 
    from cmmurray_sensor_csv
    where subsystem = "alphasense"
    """
).show()

// summarize pmi2.5 by node
val avg_pmi2 = spark.sql(
    """
    select node_id, avg(value_hrf) as avg_pmi 
    from cmmurray_sensor_csv
    where parameter = "pm2_5"
    group by node_id
    """
    )

avg_pmi2.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_avg_pmi2")

// https://www.health.nsw.gov.au/environment/air/Pages/common-air-pollutants.aspx
val no2_sum = spark.sql(
    """
    select node_id, sum(value_raw) as no2_sum, count(value_raw) as no2_obs
    from cmmurray_sensor_csv
    where sensor = "no2"
    group by node_id
    limit 5
    """
)

