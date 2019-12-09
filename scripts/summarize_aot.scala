import org.apache.spark.sql.SaveMode

// bring sensor table in
val sensor = spark.table("cmmurray_sensor_csv")


// https://www.health.nsw.gov.au/environment/air/Pages/common-air-pollutants.aspx
val no2_sum = spark.sql(
    """
    select node_id, sum(value_hrf) as no2_sum, count(value_hrf) as no2_obs
    from cmmurray_sensor_csv
    where sensor = "no2"
    group by node_id
    """
)

no2_sum.write.mode(SaveMode.Overwrite).saveAsTable("cmmurray_no2_sum")

val noise_sum = spark.sql(
    """
    select node_id, value_hrf as db_sum
    from cmmurray_sensor_csv
    where parameter = "octave_1_intensity"
    limit 5;
    """
)